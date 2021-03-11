

# ProcWakeup流程

![image-20200821102143808](C:\Users\Lenovo\Desktop\image-20200821102143808.png)

finish_xact_command(void) -> CommitTransactionCommd() -> CommitTransaction() -> ResourceOwnerRelease(RESOURCE_RELEASE_LOCKS).

```c
ResourceOwnerRelease(TopTransactionResourceOwner,
					 RESOURCE_RELEASE_BEFORE_LOCKS,
					 true, true);
/* 锁释放阶段
 * ResourceOwnerRelease()只是完成资源释放的一个阶段
 */
ResourceOwnerRelease(TopTransactionResourceOwner,
						 RESOURCE_RELEASE_LOCKS,
						 true, true);
ResourceOwnerRelease(TopTransactionResourceOwner,
						 RESOURCE_RELEASE_AFTER_LOCKS,
						 true, true);
```

释放顶层事务的所有资源. 资源释放分为3个阶段: pre-locks, locks, post-locks. 

```c
/* resowner.c -> ResourceOwnerReleaseInternal() */
else if (phase == RESOURCE_RELEASE_LOCKS)
	{
		if (isTopLevel)
		{
			/*
			 * For a top-level xact we are going to release all locks (or at
			 * least all non-session locks), so just do a single lmgr call at
			 * the top of the recursion.
			 */
			if (owner == TopTransactionResourceOwner)
			{
				ProcReleaseLocks(isCommit);
				ReleasePredicateLocks(isCommit);
			}
		}
    
 

```

## 关键

```c
void
ProcReleaseLocks(bool isCommit)
{	
	LockReleaseAll(DEFAULT_LOCKMETHOD, !isCommit);	
}

if (lockmethodid <= 0 || lockmethodid >= lengthof(LockMethods))
		elog(ERROR, "unrecognized lock method: %d", lockmethodid);
	lockMethodTable = LockMethods[lockmethodid];


void
LockReleaseAll(LOCKMETHODID lockmethodid, bool allLocks)
{
    CleanUpLock(lock, proclock,
						lockMethodTable,
						LockTagHashCode(&lock->tag),
						wakeupNeeded);
}

void
ProcLockWakeup(LockMethod lockMethodTable, LOCK *lock)
{
    
}

```



## ProcReleaseLocks

```c
void
ProcReleaseLocks(bool isCommit)
{
	if (!MyProc)
		return;
	/* If waiting, get off wait queue (should only be needed after error) */
	LockErrorCleanup();
	/* Release standard locks, including session-level if aborting */
	LockReleaseAll(DEFAULT_LOCKMETHOD, !isCommit);		/* 事务锁释放在这里 */
	/* Release transaction-level advisory locks */
	LockReleaseAll(USER_LOCKMETHOD, false);
}
```

## 唤醒等待者

```c
/* lock.c -> LockReleaseAll() */
/* CleanUpLock will wake up waiters if needed. 
 * 在这里唤醒等待此事务的等待者
 */
			CleanUpLock(lock, proclock,
						lockMethodTable,
						LockTagHashCode(&lock->tag),
						wakeupNeeded);
```



## ProcLockWakeup

每个Lock都有自己的等待进程队列(lock->waitProcs)

```c
while (queue_size-- > 0)
	{
		LOCKMODE	lockmode = proc->waitLockMode;

		/*
		 * Waken if (a) doesn't conflict with requests of earlier waiters, and
		 * (b) doesn't conflict with already-held locks.
		 * *唤醒，如果(a)不与早期等待者的请求冲突，* (b)不与已经持有的锁冲突*
		 */
		if ((lockMethodTable->conflictTab[lockmode] & aheadRequests) == 0 &&
			LockCheckConflicts(lockMethodTable,
							   lockmode,
							   lock,
							   proc->waitProcLock) == STATUS_OK)
		{
			/* OK to waken */
			GrantLock(lock, proc->waitProcLock, lockmode);
			proc = ProcWakeup(proc, STATUS_OK);	/* 唤醒等待的进程 */

			/*
			 * ProcWakeup removes proc from the lock's waiting process queue
			 * and returns the next proc in chain; don't use proc's next-link,
			 * because it's been cleared.
			 */
		}
		else
```

## SetLatch

```c
UXPROC *
ProcWakeup(UXPROC *proc, int waitStatus)
{
	UXPROC	   *retProc;

	/* Proc should be sleeping ... */
    /* 唤醒的进程必须在等待队列中 */
	if (proc->links.prev == NULL ||
		proc->links.next == NULL)
		return NULL;
	Assert(proc->waitStatus == STATUS_WAITING);	/* 唤醒的进程的状态必须是等待中 */

	/* Save next process before we zap the list link 
	 * 在删除列表链接之前保存下一个进程
	 */
	retProc = (UXPROC *) proc->links.next;

	/* Remove process from wait queue */
	SHMQueueDelete(&(proc->links));
	(proc->waitLock->waitProcs.size)--;

	/* Clean up process' state and pass it the ok/fail signal 
	 * 清除进程状态并传递ok/fail信号
	 */
	proc->waitLock = NULL;
	proc->waitProcLock = NULL;
	proc->waitStatus = waitStatus;	/* 默认都是STATUS_OK */

	/* And awaken it */
	SetLatch(&proc->procLatch);		/* 

	return retProc;
}
```



## 写写并发控制接口定义

```c
/* 指定事务是否存在waiter */
bool wakeupNeeded(Transaction xid)
{
}

/* 获取指定事务被等待的锁 */
Lock* getLock(Transaction xid)
{
}

/* 获取等待锁的LockMethodTable */
LockMethodTable* getLockMethodTable(Lock *lock)
{
    return GetLocksMethodTable(lock);
}

/* 唤醒等待锁的进程 */
void ProcLockWakeup(LOCK *lock)
{
	PROC_QUEUE *waitQueue = &(lock->waitProcs);
	int queue_size = waitQueue->size;
	UXPROC *proc;
	LOCKMASK aheadRequests = 0;

	Assert(queue_size >= 0);

	if (queue_size == 0)
		return;

	proc = (UXPROC *)waitQueue->links.next;

	while (queue_size-- > 0)
	{
		LOCKMODE lockmode = proc->waitLockMode;

		/* OK to waken */
		GrantLock(lock, proc->waitProcLock, lockmode);
		proc = ProcWakeup(proc, STATUS_OK);

		/*
			 * ProcWakeup removes proc from the lock's waiting process queue
			 * and returns the next proc in chain; don't use proc's next-link,
			 * because it's been cleared.
			 */
	}

	Assert(waitQueue->size >= 0);
}

/* 唤醒等待锁的进程 */
void
ProcLockWakeup(LockMethod lockMethodTable, LOCK *lock)
{
	PROC_QUEUE *waitQueue = &(lock->waitProcs);
	int			queue_size = waitQueue->size;
	UXPROC	   *proc;
	LOCKMASK	aheadRequests = 0;

	Assert(queue_size >= 0);

	if (queue_size == 0)
		return;

	proc = (UXPROC *) waitQueue->links.next;

	while (queue_size-- > 0)
	{
		LOCKMODE	lockmode = proc->waitLockMode;

		/*
		 * Waken if (a) doesn't conflict with requests of earlier waiters, and
		 * (b) doesn't conflict with already-held locks.
		 */
		if ((lockMethodTable->conflictTab[lockmode] & aheadRequests) == 0 &&
			LockCheckConflicts(lockMethodTable,
							   lockmode,
							   lock,
							   proc->waitProcLock) == STATUS_OK)
		{
			/* OK to waken */
			GrantLock(lock, proc->waitProcLock, lockmode);
			proc = ProcWakeup(proc, STATUS_OK);

			/*
			 * ProcWakeup removes proc from the lock's waiting process queue
			 * and returns the next proc in chain; don't use proc's next-link,
			 * because it's been cleared.
			 */
		}
		else
		{
			/*
			 * Cannot wake this guy. Remember his request for later checks.
			 */
			aheadRequests |= LOCKBIT_ON(lockmode);
			proc = (UXPROC *) proc->links.next;
		}
	}

	Assert(waitQueue->size >= 0);
}
```



