# heap_acquire_tuplock和ExecLockRows区别说明

by 刘海峰 2020.12.25

## 概述

从函数字面意思来看, heap_acquire_tuplock和ExecLockRows 都有行锁定的意味, 那么这两者有什么样的区分. 本文了解UXDB中heap_acquire_tuplock和ExecLockRows作用和区别.

## 调用流程

heap_acquire_tuplock -> LockTupleTuplock -> LockTuple -> LockAcquire

ExecLockRows -> heap_lock_tuple -> compute_new_xmax_infomask

## 调用堆栈

开启2个事务, 同时update同一行, 那么第2个事务会先在目标行上请求行锁, 让后等待事务1结束.

```c
#0  LockAcquire (locktag=0x7ffcb1f51850, lockmode=7, sessionLock=0 '\000', dontWait=0 '\000') at lock.c:709
#1  0x00000000007fa538 in LockTuple (relation=0x7f7327621268, tid=0x7ffcb1f51914, lockmode=7) at lmgr.c:466
#2  0x00000000004bf8e6 in heap_acquire_tuplock (relation=0x7f7327621268, tid=0x7ffcb1f51914, mode=LockTupleNoKeyExclusive, wait_policy=LockWaitBlock, have_tuple_lock=0x7ffcb1f51903 "") at heapam.c:5434
#3  0x00000000004bcccc in heap_update (relation=0x7f7327621268, otid=0x7ffcb1f51b12, newtup=0x2032680, cid=0, crosscheck=0x0, wait=1 '\001', hufd=0x7ffcb1f51a60, lockmode=0x7ffcb1f51a5c) at heapam.c:3850
#4  0x00000000006a0b41 in ExecUpdate (mtstate=0x2030a58, tupleid=0x7ffcb1f51b12, oldtuple=0x0, slot=0x20321e0, planSlot=0x2031808, epqstate=0x2030b08, estate=0x2030708, canSetTag=1 '\001') at nodeModifyT
able.c:1060
#5  0x00000000006a1bb0 in ExecModifyTable (pstate=0x2030a58) at nodeModifyTable.c:1773
#6  0x000000000067e5c7 in ExecProcNodeFirst (node=0x2030a58) at execProcnode.c:430
#7  0x0000000000677483 in ExecProcNode (node=0x2030a58) at ../../../src/include/executor/executor.h:250
#8  0x0000000000679926 in ExecutePlan (estate=0x2030708, planstate=0x2030a58, use_parallel_mode=0 '\000', operation=CMD_UPDATE, sendTuples=0 '\000', numberTuples=0, direction=ForwardScanDirection, dest=0
x20222d8, execute_once=1 '\001') at execMain.c:1722
#9  0x0000000000677927 in standard_ExecutorRun (queryDesc=0x205bb48, direction=ForwardScanDirection, count=0, execute_once=1 '\001') at execMain.c:363
#10 0x00000000006777c8 in ExecutorRun (queryDesc=0x205bb48, direction=ForwardScanDirection, count=0, execute_once=1 '\001') at execMain.c:306
#11 0x000000000081aa99 in ProcessQuery (plan=0x20221f8, sourceText=0x2002c88 "update a set info=1 where id=1;", params=0x0, queryEnv=0x0, dest=0x20222d8, completionTag=0x7ffcb1f51f00 "") at pquery.c:161
#12 0x000000000081c213 in PortalRunMulti (portal=0x206e228, isTopLevel=1 '\001', setHoldSnapshot=0 '\000', dest=0x20222d8, altdest=0x20222d8, completionTag=0x7ffcb1f51f00 "") at pquery.c:1286
#13 0x000000000081b85b in PortalRun (portal=0x206e228, count=9223372036854775807, isTopLevel=1 '\001', run_once=1 '\001', dest=0x20222d8, altdest=0x20222d8, completionTag=0x7ffcb1f51f00 "") at pquery.c:7
99
#14 0x0000000000815caf in exec_simple_query (query_string=0x2002c88 "update a set info=1 where id=1;") at postgres.c:1144
#15 0x0000000000819cdb in PostgresMain (argc=1, argv=0x1fad140, dbname=0x1fad038 "postgres", username=0x1fad018 "postgres") at postgres.c:4133
#16 0x000000000078c03a in BackendRun (port=0x1fa75f0) at postmaster.c:4357
#17 0x000000000078b7d4 in BackendStartup (port=0x1fa75f0) at postmaster.c:4029
#18 0x000000000078816c in ServerLoop () at postmaster.c:1753
#19 0x00000000007877ee in PostmasterMain (argc=3, argv=0x1f80da0) at postmaster.c:1361
#20 0x00000000006cebe5 in main (argc=3, argv=0x1f80da0) at main.c:228
```



在表上执行select * from a for share;  或 select * from a for update;

```c
compute_new_xmax_infomask(xmax, old_infomask, tuple->t_data->t_infomask2,                           				GetCurrentTransactionId(), mode, false, &xid, &new_infomask, &new_infomask2);
#0  heap_lock_tuple (relation=0x7f7327621268, tuple=0x7ffcb1f51b20, cid=0, mode=LockTupleShare, wait_policy=LockWaitBlock, follow_updates=1 '\001', buffer=0x7ffcb1f51b1c, hufd=0x7ffcb1f51b00) at heapam.c
:4765
#1  0x000000000069b12c in ExecLockRows (pstate=0x20309e8) at nodeLockRows.c:183
#2  0x000000000067e5c7 in ExecProcNodeFirst (node=0x20309e8) at execProcnode.c:430
#3  0x0000000000677483 in ExecProcNode (node=0x20309e8) at ../../../src/include/executor/executor.h:250
#4  0x0000000000679926 in ExecutePlan (estate=0x2030708, planstate=0x20309e8, use_parallel_mode=0 '\000', operation=CMD_SELECT, sendTuples=1 '\001', numberTuples=0, direction=ForwardScanDirection, dest=0
x2021da0, execute_once=1 '\001') at execMain.c:1722
#5  0x0000000000677927 in standard_ExecutorRun (queryDesc=0x205bb48, direction=ForwardScanDirection, count=0, execute_once=1 '\001') at execMain.c:363
#6  0x00000000006777c8 in ExecutorRun (queryDesc=0x205bb48, direction=ForwardScanDirection, count=0, execute_once=1 '\001') at execMain.c:306
#7  0x000000000081babb in PortalRunSelect (portal=0x206e228, forward=1 '\001', count=0, dest=0x2021da0) at pquery.c:932
#8  0x000000000081b795 in PortalRun (portal=0x206e228, count=9223372036854775807, isTopLevel=1 '\001', run_once=1 '\001', dest=0x2021da0, altdest=0x2021da0, completionTag=0x7ffcb1f51f00 "") at pquery.c:7
73
#9  0x0000000000815caf in exec_simple_query (query_string=0x2002c88 "select * from a for share;") at postgres.c:1144
#10 0x0000000000819cdb in PostgresMain (argc=1, argv=0x1fad140, dbname=0x1fad038 "postgres", username=0x1fad018 "postgres") at postgres.c:4133
#11 0x000000000078c03a in BackendRun (port=0x1fa75f0) at postmaster.c:4357
#12 0x000000000078b7d4 in BackendStartup (port=0x1fa75f0) at postmaster.c:4029
#13 0x000000000078816c in ServerLoop () at postmaster.c:1753
#14 0x00000000007877ee in PostmasterMain (argc=3, argv=0x1f80da0) at postmaster.c:1361
#15 0x00000000006cebe5 in main (argc=3, argv=0x1f80da0) at main.c:228

```

## 区别

### 区别1 加锁流程不同

heap_acquire_tuplock -> LockTupleTuplock -> LockTuple -> LockAcquire

ExecLockRows -> heap_lock_tuple -> compute_new_xmax_infomask

LockTupleTuplock - 在tuple上获取常规锁(Acquire heavyweight locks on tuples)

heap_lock_tuple - 以共享或独占模式锁定元组

### 区别2 存储位置不同

heap_acquire_tuplock请求的行锁, 保存在共享内存的锁管理器(LockMethodLockHash)中.

heap_lock_tuple  请求的锁, 保存在tuple的组合事务(MultiXact)中.

### 区别3 数量不同

使用heap_acquire_tuplock施加的行锁一般均是互斥的, 如LockTupleNoKeyExclusive 或 LockTupleExclusive.

而共享的行锁, 如 LockTupleKeyShare 或 LockTupleShare是记录在组合事务中的.

共享内存空间是有限的, 所以共享内存中的锁管理器(LockMethodLockHash)能够记录的行锁数量也是有限的, 所以只能记录互斥行锁, 而组合事务通过使用组合事务日志, 可以记录任意个共享的行锁.

### 区别4 使用方式的差异

UXDB MVCC并发出现写写冲突时,  如: 事务A和事务B冲突, 冲突的事务B如果确定需要等待, 那么会先在要操作的行范围(tuples range)中的第一行施加行锁, 然后开始等待事务A完结. 这时如果有事务C, 事务D等等, 也想要修改相同的行, 那么它们会被加入到"行锁"的等待队列中. 并且这里施加的行锁, 是隐式施加的, 即是由于MVCC写写并发出现了冲突, UXDB底层自动施加的, 用户层无法干涉.

> MVCC写写冲突, 与写写相关的入口函数有2个:  heap_update 和 heap_delete.

而heap_lock_tuple, 用户层通过执行select for key share, select for share, select for no key update和select for update 这4个SQL语句中的任何一个, 就可以出发底层调用heap_lock_tuple来向选中行施加行锁.  当然, heap_lock_tuple也存在UXDB自动施加的场景: 向外键应用表并发插入数据行时, 底层外键约束机制会自动向外键表施加 for key share级别的行锁, 这时也会调用到heap_lock_tuple.

### 区别5 各自使用的目的或用途



## 其他

### Q 什么情况下, heap_lock_tuple中会调用heap_acquire_tuplock, 即行锁创建到LockMethodLockHash, 而非MultiXact中?

用户层执行select for key share, select for share, select for no key update和select for update时, 如果出现了锁冲突, 需要等待, 那么就在heap_lock_tuple中调用heap_acquire_tuplock, 将互斥的行锁创建到LockMethodLockHash中, 已实现"行锁等待和后续的唤醒".

如果没有锁冲突等待, 说明请求的行锁可以得到, 那么在heap_lock_tuple中将锁信息直接记录到tuple的xmax中, 如果xmax记录的行锁超过1个, 则将普通事务转换为组合事务.

```c
else if (require_sleep)
		{
			/*
			 * Acquire tuple lock to establish our priority for the tuple, or
			 * die trying.  LockTuple will release us when we are next-in-line
			 * for the tuple.  We must do this even if we are share-locking.
			 *
			 * If we are forced to "start over" below, we keep the tuple lock;
			 * this arranges that we stay at the head of the line while
			 * rechecking tuple state.
			 */
			if (!heap_acquire_tuplock(relation, tid, mode, wait_policy,
									  &have_tuple_lock))
			{
				/*
				 * This can only happen if wait_policy is Skip and the lock
				 * couldn't be obtained.
				 */
				result = HeapTupleWouldBlock;
				/* recovery code expects to have buffer lock held */
				LockBuffer(*buffer, BUFFER_LOCK_EXCLUSIVE);
				goto failed;
			}
```

### heap_acquire_tuplock 概述

```c
static bool
heap_acquire_tuplock(Relation relation, ItemPointer tid, LockTupleMode mode,
					 LockWaitPolicy wait_policy, bool *have_tuple_lock)
```

在指定的tuple获得重量级锁(heavyweight lock), 为"在它的xmax上获得常规的tuple lock"做准备.

> *Acquire heavyweight lock on the given tuple, in preparation for acquiring*
>
>  its normal, Xmax-based tuple lock.*

### heap_lock_tuple 概述

```c
HTSU_Result
heap_lock_tuple(Relation relation, HeapTuple tuple,
				CommandId cid, LockTupleMode mode, LockWaitPolicy wait_policy,
				bool follow_updates,
				Buffer *buffer, HeapUpdateFailureData *hufd)
```

以共享或排他的方式锁住一个tuple, 即施加行锁.

> lock a tuple in shared or exclusive mode

注意: heap_lock_tuple中可能会调用heap_acquire_tuplock, 因此在施加行锁时如果需要等待(sleep), 那么首先会在LockMethodLockHash中施加重量级行锁, 并进行等待, 等待成功后, 再在tuple的组合事务中施加行锁.