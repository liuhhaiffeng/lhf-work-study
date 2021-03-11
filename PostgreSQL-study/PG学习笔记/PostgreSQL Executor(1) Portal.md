# PostgreSQL Executor(1): Portal

[![img](https://upload.jianshu.io/users/upload_avatars/16089749/6b314d9d-414c-43f0-a2b5-bd65b6f71690.jpg?imageMogr2/auto-orient/strip|imageView2/1/w/96/h/96/format/webp)](https://www.jianshu.com/u/c0f5b956c03b)

[DavidLi2010](https://www.jianshu.com/u/c0f5b956c03b)关注

0.9182019.05.19 12:54:14字数 1,312阅读 636

参考：[https://www.cnblogs.com/flying-tiger/p/6100794.html/](https://links.jianshu.com/go?to=https%3A%2F%2Fwww.cnblogs.com%2Fflying-tiger%2Fp%2F6100794.html%2F)

Portal的字面意是“入口”。在PostgreSQL中，Portal用来表示一个正在执行的或者是可执行的查询的执行状态。

Portal记录了与执行相关的所有信息，例如查询树、计划树和执行状态。确实可以将Portal看作执行查询计划的“入口”。

对于用户提交的普通查询语句，在服务端会创建一个匿名的Portal对象。而对于SQL中的游标声明语句，也会创建一个对应的Portal对象。

## Portal的数据

执行器使用`PortalData`来存储查询计划树、结果元组的描述符(TupleDesc)、执行状态、查询结果等数据。`PortalData`结构体定义在`src/include/utils/portal.h`中。



```c
typedef struct PortalData
{
    /* Bookkeeping data */
    const char *name;           /* portal's name */
    ......
    /* The query or queries the portal will execute */
    const char *sourceText;     /* text of query (as of 8.4, never NULL) */
    const char *commandTag;     /* command tag for original query */
    List       *stmts;          /* PlannedStmts and/or utility statements */
    ......
    ParamListInfo portalParams; /* params to pass to query */

    /* Features/options */
    PortalStrategy strategy;    /* see above */

    /* If not NULL, Executor is active; call ExecutorEnd eventually: */
    QueryDesc  *queryDesc;      /* info needed for executor invocation */

    /* If portal returns tuples, this is their tupdesc: */
    TupleDesc   tupDesc;        /* descriptor for result tuples */
    ......
}   PortalData;
```

## Portal的状态

Portal有六种状态，它们的定义如下：



```c
/*
 * A portal is always in one of these states.  It is possible to transit
 * from ACTIVE back to READY if the query is not run to completion;
 * otherwise we never back up in status.
 */
typedef enum PortalStatus
{
    PORTAL_NEW,                  /* freshly created */
    PORTAL_DEFINED,              /* PortalDefineQuery done */
    PORTAL_READY,                /* PortalStart complete, can run it */
    PORTAL_ACTIVE,               /* portal is running (can't delete it) */
    PORTAL_DONE,                 /* portal is finished (don't re-run it) */
    PORTAL_FAILED                /* portal got error (can't re-run it) */
} PortalStatus;
```

在Portal刚被创建时，状态为`PORTAL_NEW`。

通过`PortalDefineQuery`将查询计划等数据设置到Portal上之后，Portal的状态变为`PORTAL_DEFINED`。

通过`PortalStart`为执行做好准备之后，Portal的状态变为`PORTAL_READY`。

在`PortalRun`的开始，会将Portal的状态标记为`PORTAL_ACTIVE`。在`PORTAL_MULTI_QUERY`的执行策略下，在执行完成后会将Portal的状态变更为`PORTAL_DONE`，而在其它执行策略下，会将状态变更为`PORTAL_READY`。

而在上述过程中发生错误，都会将Portal的状态设置为`PORTAL_FAILED`。

## 可优化语句和不可优化语句

PostgreSQL将用户输入的SQL语句分为两类：可优化语句(Optimizable Statement)和不可优化语句(Non-optimizable Statement)。

可优化语句就是通常讲的DML语句，包括INSERT/DELETE/UPDATE/SELECT。这类语句都要查询到满足条件的远组并返回给用户。在查询优化阶段会根据查询优化理论进行重写和优化以提高查询效率，因此称为可优化语句。

不可优化语句包括DDL、DCL等语句，例如创建表、删除表、创建用户等。这类语句包含查询数据之外的各类操作，功能相对独立，因此也称为功能性语句。功能性语句没有优化的价值。

## Portal的执行策略

Portal有五种执行策略：



```c
typedef enum PortalStrategy
{
    PORTAL_ONE_SELECT,
    PORTAL_ONE_RETURNING,
    PORTAL_ONE_MOD_WITH,
    PORTAL_UTIL_SELECT,
    PORTAL_MULTI_QUERY
} PortalStrategy;
```

Portal采用哪种优化策略取决于执行的是什么样子的查询。需要注意的是，在用户角度看到的一个单一的查询语句经过查询重写之后可能会变成零个或多个实际的查询。

- PORTAL_ONE_SELECT

  Portal只包含一个`SELECT`查询。因为需要查询结果，因此执行器被递增的执行。这个策略也支持holdable的游标（执行结果可以存储到tuplestore中，以便在事务完成后访问）。

- PORTAL_ONE_RETURNING

  Portal包含一个带有`RETURNING`子句（另外也可能有查询重写增加的辅助查询）的`INSERT/UPDATE/DELETE`查询。在第一次执行时，Portal被执行完成，并将主查询的结果存储到Portal的tuplestore中，然后将结果返回给客户端。

- PORTAL_ONE_MOD_WITH

  Portal包含一个`SELECT`查询，同时存在修改数据的CTE(Common Table Expression)。当前处理方式与`PORTAL_ONE_RETURNING`相同。

- PORTAL_UTIL_SELECT

  Portal包含一个功能性(Utility)语句，返回类似于`SELECT`的结果（比如EXPLAIN和SHOW）。在第一次执行时，Portal被执行完成，并将主查询的结果存储到Portal的tuplestore中，然后将结果返回给客户端。

- PORTAL_MULTI_QUERY

  包含所有其它情况。Portal不支持部分执行：在Portal第一次执行时完成所有的查询。

具体代码位于`src/backend/tcop/pquery.c`中函数`ChoosePortalStrategy`。

## Portal的执行

所有SQL语句的执行都必须从一个Portal开始。Portal的执行流程依次经历`PortalStart`、`PortalRun`、`PortalDrop`三个过程。每种执行策略都实现了单独的执行流程，会经历不同的处理过程。

所有流程都在`exec_simple_query`函数内部进行。Portal的执行流程如下：

1. 调用函数`CreatePortal`创建一个干净的Portal，它的内存上下文、资源跟踪器清理函数都已经设置好，但是sourceText、stmts字段还未设置；
2. 调用函数`PortalDefineQuery`为刚刚创建的Portal设置sourceText、stmt等，并且设置Portal的状态为PORTAL_DEFINED；
3. 调用函数`PortalStart`对定义好的Portal进行初始化：
   1. 调用函数`ChoosePortalStrategy`为portal选择策略；
   2. 如果选择的是`PORTAL_ONE_SELECT`，则调用`CreateQueryDesc`为Portal创建查询描述符；
   3. 如果选择的是`PORTAL_ONE_RETURNING`或者`PORTAL_ONE_MOD_WITH`，则调用`ExecCleanTypeFromTL`为Portal创建返回元组的描述符；
   4. 对于`PORTAL_UTIL_SELECT`则调用`UtilityTupleDescriptor`为Portal创建查询描述符；
   5. 对于`PORTAL_MULTI_QUERY`这里则不做操作；
   6. 将Portal的状态设置为`PORTAL_READY`。
4. 调用函数`PortalRun`执行Portal,这就按照既定的策略调用相关执行部件执行Portal；
5. 调用函数`PortalDrop`清理Portal，释放资源。