# PostgreSQL中的RegularLock

[![someoneATwu](https://pic3.zhimg.com/v2-451373cd9472c45062e41ca80b3af918_xs.jpg?source=172ae18b)](https://www.zhihu.com/people/drecwu)

[someoneATwu](https://www.zhihu.com/people/drecwu)

I know nothing...

已关注

4 人赞同了该文章

RegularLock又称为HeavyweightLock，在PostgreSQL中我们常说的表锁，指的其实就是这类锁。因为，对于用户来说，关心的是表，数据库，page等数据库的对象，而之前所介绍的SpinLock和LWLock保护对象的是数据库内部实现的数据结构。相比与SpinLock和LWLock，RegularLock的加锁开销非常大，因为加锁时要额外记录锁的持有者，加锁次数，请求次数等额外信息。

## 1. what is RegularLock?

这里从几个关键的数据结构来了解RegularLock。

**LockMethod：**指定了加锁的方法，即可以加的锁模式（排他、共享等）个数，不同锁模式的间的冲突矩阵。当前PG中又两种锁方法：DEFAULT_LOCKMETHOD和USER_LOCKMETHOD。其中，DEFAULT_LOCKMETHOD是系统默认使用的锁方法，如RelationLock，tupleLock等；USER_LOCKMETHOD是用户自定义的锁方法，如pg advisory lock。

```cpp
typedef struct LockMethodData
{
	int			numLockModes; //锁模式数量，读/写等
	const LOCKMASK *conflictTab; // 不同锁模式间的冲突矩阵
	const char *const *lockModeNames; // LockMethod名
	const bool *trace_flag; // 用户debug信息输出
} LockMethodData;
```

锁方法的核心是冲突矩阵的定义，目前PG中RegularLock的锁模式共有8种，其具体的使用场景如注释所示：

```cpp
#define AccessShareLock			1	/* SELECT */
#define RowShareLock			2	/* SELECT FOR UPDATE/FOR SHARE */
#define RowExclusiveLock		3	/* INSERT, UPDATE, DELETE */
#define ShareUpdateExclusiveLock 4	/* VACUUM (non-FULL),ANALYZE, CREATE INDEX
									 * CONCURRENTLY */
#define ShareLock				5	/* CREATE INDEX (WITHOUT CONCURRENTLY) */
#define ShareRowExclusiveLock	6	/* like EXCLUSIVE MODE, but allows ROW
									 * SHARE */
#define ExclusiveLock			7	/* blocks ROW SHARE/SELECT...FOR UPDATE */
#define AccessExclusiveLock		8	/* ALTER TABLE, DROP TABLE, VACUUM FULL,
									 * and unqualified LOCK TABLE */
```

各种锁模式之间的冲突如下所示：

```cpp
static const LOCKMASK LockConflicts[] = {
	0,

	/* AccessShareLock */
        // AccessShareLock仅与AccessExclusiveLock冲突
	LOCKBIT_ON(AccessExclusiveLock), 
	/* RowShareLock */
        // RowShareLock与ExclusiveLock和AccessExclusiveLock冲突
	LOCKBIT_ON(ExclusiveLock) | LOCKBIT_ON(AccessExclusiveLock),

	/* RowExclusiveLock */
        // RowExclusiveLock与ShareLock、ShareRowExclusiveLock、ExclusiveLock、AccessExclusiveLock冲突
	LOCKBIT_ON(ShareLock) | LOCKBIT_ON(ShareRowExclusiveLock) |
	LOCKBIT_ON(ExclusiveLock) | LOCKBIT_ON(AccessExclusiveLock),

	/* ShareUpdateExclusiveLock */
        // ShareUpdateExclusiveLock与ShareUpdateExclusiveLock、ShareLock、ShareRowExclusiveLock、
        // ExclusiveLock、AccessExclusiveLock冲突
	LOCKBIT_ON(ShareUpdateExclusiveLock) |
	LOCKBIT_ON(ShareLock) | LOCKBIT_ON(ShareRowExclusiveLock) |
	LOCKBIT_ON(ExclusiveLock) | LOCKBIT_ON(AccessExclusiveLock),

	/* ShareLock */
        // ShareLock与RowExclusiveLock、ShareUpdateExclusiveLock、ShareRowExclusiveLock
        // ExclusiveLock、AccessExclusiveLock冲突
	LOCKBIT_ON(RowExclusiveLock) | LOCKBIT_ON(ShareUpdateExclusiveLock) |
	LOCKBIT_ON(ShareRowExclusiveLock) |
	LOCKBIT_ON(ExclusiveLock) | LOCKBIT_ON(AccessExclusiveLock),

	/* ShareRowExclusiveLock */
        // ShareRowExclusiveLock与RowExclusiveLock、ShareUpdateExclusiveLock、
        // ShareLock、ShareRowExclusiveLock、ExclusiveLock、AccessExclusiveLock冲突
	LOCKBIT_ON(RowExclusiveLock) | LOCKBIT_ON(ShareUpdateExclusiveLock) |
	LOCKBIT_ON(ShareLock) | LOCKBIT_ON(ShareRowExclusiveLock) |
	LOCKBIT_ON(ExclusiveLock) | LOCKBIT_ON(AccessExclusiveLock),

	/* ExclusiveLock */
        // ExclusiveLock 与 RowShareLock、RowExclusiveLock、ShareUpdateExclusiveLock、
        // ShareLock、ShareRowExclusiveLock、ExclusiveLock、AccessExclusiveLock冲突
	LOCKBIT_ON(RowShareLock) |
	LOCKBIT_ON(RowExclusiveLock) | LOCKBIT_ON(ShareUpdateExclusiveLock) |
	LOCKBIT_ON(ShareLock) | LOCKBIT_ON(ShareRowExclusiveLock) |
	LOCKBIT_ON(ExclusiveLock) | LOCKBIT_ON(AccessExclusiveLock),

	/* AccessExclusiveLock */
        // 与所有其它锁包括自身冲突
	LOCKBIT_ON(AccessShareLock) | LOCKBIT_ON(RowShareLock) |
	LOCKBIT_ON(RowExclusiveLock) | LOCKBIT_ON(ShareUpdateExclusiveLock) |
	LOCKBIT_ON(ShareLock) | LOCKBIT_ON(ShareRowExclusiveLock) |
	LOCKBIT_ON(ExclusiveLock) | LOCKBIT_ON(AccessExclusiveLock)

};
```

**LOCK：**此数据结构定义了锁对象，包含锁表对象的标识，当前被加的锁类型，当前等锁的锁类型，加锁请求的次数和加锁成功的次数等等：

```cpp
typedef struct LOCK
{
	/* hash key */
	LOCKTAG		tag;			/* unique identifier of lockable object */

	/* data */
	LOCKMASK	grantMask;		/* bitmask for lock types already granted */
	LOCKMASK	waitMask;		/* bitmask for lock types awaited */
	SHM_QUEUE	procLocks;		/* list of PROCLOCK objects assoc. with lock */
	PROC_QUEUE	waitProcs;		/* list of PGPROC objects waiting on lock */
	int			requested[MAX_LOCKMODES];	/* counts of requested locks */
	int			nRequested;		/* total of requested[] array */
	int			granted[MAX_LOCKMODES]; /* counts of granted locks */
	int			nGranted;		/* total of granted[] array */
} LOCK;
```

其中，tag是加锁的类型，表明是relation锁、page锁、行锁、事务锁等中的何种锁。对于relation锁，会记录relation对应的db oid + relation oid，对于page锁则记录：db oid + relation oid + block number，其它依此类推：

```cpp
typedef enum LockTagType
{
	LOCKTAG_RELATION,			/* whole relation */
	/* ID info for a relation is DB OID + REL OID; DB OID = 0 if shared */
	LOCKTAG_RELATION_EXTEND,	/* the right to extend a relation */
	/* same ID info as RELATION */
	LOCKTAG_PAGE,				/* one page of a relation */
	/* ID info for a page is RELATION info + BlockNumber */
	LOCKTAG_TUPLE,				/* one physical tuple */
	/* ID info for a tuple is PAGE info + OffsetNumber */
	LOCKTAG_TRANSACTION,		/* transaction (for waiting for xact done) */
	/* ID info for a transaction is its TransactionId */
	LOCKTAG_VIRTUALTRANSACTION, /* virtual transaction (ditto) */
	/* ID info for a virtual transaction is its VirtualTransactionId */
	LOCKTAG_SPECULATIVE_TOKEN,	/* speculative insertion Xid and token */
	/* ID info for a transaction is its TransactionId */
	LOCKTAG_OBJECT,				/* non-relation database object */
	/* ID info for an object is DB OID + CLASS OID + OBJECT OID + SUBID */

	/*
	 * Note: object ID has same representation as in pg_depend and
	 * pg_description, but notice that we are constraining SUBID to 16 bits.
	 * Also, we use DB OID = 0 for shared objects such as tablespaces.
	 */
	LOCKTAG_USERLOCK,			/* reserved for old contrib/userlock code */
	LOCKTAG_ADVISORY			/* advisory user locks */
} LockTagType;
```

procLocks里存储的是持有该锁的backend，关于backend的相关信息描述存储在了PROLOCK结构体当中：

```cpp
typedef struct PROCLOCKTAG
{
	/* NB: we assume this struct contains no padding! */
	LOCK	   *myLock;			/* link to per-lockable-object information */
	PGPROC	   *myProc;			/* link to PGPROC of owning backend */
} PROCLOCKTAG;

typedef struct PROCLOCK
{
	/* tag */
	PROCLOCKTAG tag;			/* unique identifier of proclock object */

	/* data */
	PGPROC	   *groupLeader;	/* proc's lock group leader, or proc itself */
	LOCKMASK	holdMask;		/* bitmask for lock types currently held */
	LOCKMASK	releaseMask;	/* bitmask for lock types to be released */
	SHM_QUEUE	lockLink;		/* list link in LOCK's list of proclocks */
	SHM_QUEUE	procLink;		/* list link in PGPROC's list of proclocks */
} PROCLOCK;
```

**LOCALLOCK**：每个backend也维护了其当前正持有的锁和需要加锁的相关信息。这样，对于其正在持有的锁，如果backend有新的加锁请求，那么就无需再访问共享内存。同时也记录了持有该锁的ResourceOwner，这样就可以指定某一类型的资源来释放锁。

> ResourceOwner objects are a concept invented to simplify management of query-related resources, such as buffer pins and table locks. These resources need to be tracked in a reliable way to ensure that they will be released at query end, even if the query fails due to an error. Rather than expecting the entire executor to have bulletproof data structures, we localize the tracking of such resources into a single module. **We create a ResourceOwner for each transaction or subtransaction as well as one for each Portal.**

```cpp
typedef struct LOCALLOCKTAG
{
	LOCKTAG		lock;			/* identifies the lockable object */
	LOCKMODE	mode;			/* lock mode for this table entry */
} LOCALLOCKTAG;

typedef struct LOCALLOCKOWNER
{
	/*
	 * Note: if owner is NULL then the lock is held on behalf of the session;
	 * otherwise it is held on behalf of my current transaction.
	 *
	 * Must use a forward struct reference to avoid circularity.
	 */
	struct ResourceOwnerData *owner;
	int64		nLocks;			/* # of times held by this owner */
} LOCALLOCKOWNER;

typedef struct LOCALLOCK
{
	/* tag */
	LOCALLOCKTAG tag;			/* unique identifier of locallock entry */

	/* data */
	LOCK	   *lock;			/* associated LOCK object, if any */
	PROCLOCK   *proclock;		/* associated PROCLOCK object, if any */
	uint32		hashcode;		/* copy of LOCKTAG's hash value */
	int64		nLocks;			/* total number of times lock is held */
	int			numLockOwners;	/* # of relevant ResourceOwners */
	int			maxLockOwners;	/* allocated size of array */
	bool		holdsStrongLockCount;	/* bumped FastPathStrongRelationLocks */
	LOCALLOCKOWNER *lockOwners; /* dynamically resizable array */
} LOCALLOCK;
```

## 2. 锁操作

主要从加锁和放锁这两方面来介绍RegularLock 的锁操作

**加锁操作**

主体逻辑在函数LockAcquire(const LOCKTAG *locktag, LOCKMODE lockmode, bool sessionLock, bool dontWait)中：

1. 查找backend本地的LOCALLOCK，如果存在该lock，并且当前backend已经持有了该锁，则直接赋予该锁，granted的次数+1。
2. 如果1中不符合授予条件，则通过fastpath来获取锁。通过fastpasth授予锁需要满足几个条件：1）加锁方法是系统默认的default方法；2）加锁的对象是relation；3）加锁的模式必须小于ShareUpdateExclusiveLock，因为小于该模式的锁互不排斥。4）每个backend，最多只能有16把锁通过fastpath获取得到。5）当前请求的锁对象，没有被加上大于ShareUpdateExclusiveLock模式的锁。fastpath加锁，首先会遍历已经通过fastpath加锁的数组，如果找到与当前匹配的锁对象，则返回加锁成功。否则，新分配一个slot，记录加锁信息，返回加锁成功。
3. 对于锁模式高于ShareUpdateExclusiveLock的锁，进行标记，下次在对其锁对象加锁时，禁止走fastpath。对与其它backend的fastpath，如果已经加了该对象的锁，则需要把该锁从fastpath中清除，然后将已经加锁的对象放入到shared hash table中记录。**这是为了保证加模式更强的锁，能够通过shared hash table检测到其它backend在这个对象上加的模式更低的锁。**
4. 在共享内存中进行加锁。为此，需要首先在共享内存中创建LOCK，PROLOCK。
5. 判断当前加锁是否与正在等锁的请求冲突，当前加锁不成功需要等待，否则，检查是否与当前已经持有（其它backend持有）的锁冲突，如果冲突，同样也需要等待。如果都不冲突，则加锁成功。
6. 如果加锁的参数dontWait为true，那么当有冲突时，不会等待，清除掉当前请求的信息，返回LOCKACQUIRE_NOT_AVAIL。否则，会将加锁请求放入等待队列中，然后休眠，直到有信号量（有释放锁）唤醒，然后在此尝试加锁。当然，在等待锁的时候，后台会进行死锁检测，检测到死锁时，可能会终止此时加锁。

**放锁操作**

1. 查找backend本地的LOCALLOCK，如果存在该lock，并且当前backend已经持有了该锁，将对应ResourceOwner的锁计数减1，如果减到了0，则ResourceOwner需要释放该锁。另外，将总的granted数量-1。
2. 如果释放的锁的锁模式小于ShareUpdateExclusiveLock，从fastpath中查找该锁，如果找到，释放对应模式的锁。
3. 如果locallock中的lock为空，那么从shared hash table中查找该锁，因为有可能该锁被其它backend从fastpath放入到了shared hash table中（加锁逻辑中）。
4. 释放该锁，如果有等待的锁请求，那么唤醒其它等待的进程。

## 3. 总结

相比于SpinLock、LWLock。RegularLock加锁的开销更大。但是提供更加丰富的锁模式，为数据库不同的操作场景提供了更细粒度的锁冲突控制，尽可能地提供了数据库的高并发访问。丰富的加锁信息，有助于DBA、应用开发人员、数据库内核开发人员优化查询、应用和系统的性能。另外，RegularLock还提供了死锁检测机制，可以系统发生死锁时，终止加锁，保证系统正常运行。





编辑于 2019-10-08