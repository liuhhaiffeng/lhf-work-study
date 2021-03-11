# vacuum oldest xmin讲解

刘海峰 2020.09.02



```c
appendStringInfo(&buf,
							 _("tuples: %.0f removed, %.0f remain, %.0f are dead but not yet removable, oldest xmin: %u\n"),
							 vacrelstats->tuples_deleted,
							 vacrelstats->new_rel_tuples,
							 vacrelstats->new_dead_tuples,
							 OldestXmin);
```


oldestXmin is the cutoff value used to distinguish whether tuples are DEAD or RECENTLY_DEAD (see HeapTupleSatisfiesVacuum).

```c
/*
 * vacuum_set_xid_limits() -- compute oldest-Xmin and freeze cutoff points
 *
 * The output parameters are:
 * - oldestXmin is the cutoff value used to distinguish whether tuples are
 *	 DEAD or RECENTLY_DEAD (see HeapTupleSatisfiesVacuum).
 * - freezeLimit is the Xid below which all Xids are replaced by
 *	 FrozenTransactionId during vacuum.
 * - xidFullScanLimit (computed from table_freeze_age parameter)
 *	 represents a minimum Xid value; a table whose relfrozenxid is older than
 *	 this will have a full-table vacuum applied to it, to freeze tuples across
 *	 the whole table.  Vacuuming a table younger than this value can use a
 *	 partial scan.
 * - multiXactCutoff is the value below which all MultiXactIds are removed from
 *	 Xmax.
 * - mxactFullScanLimit is a value against which a table's relminmxid value is
 *	 compared to produce a full-table vacuum, as with xidFullScanLimit.
 *
 * xidFullScanLimit and mxactFullScanLimit can be passed as NULL if caller is
 * not interested.
 */
void
vacuum_set_xid_limits(Relation rel,
					  int freeze_min_age,
					  int freeze_table_age,
					  int multixact_freeze_min_age,
					  int multixact_freeze_table_age,
					  TransactionId *oldestXmin,
					  TransactionId *freezeLimit,
					  TransactionId *xidFullScanLimit,
					  MultiXactId *multiXactCutoff,
					  MultiXactId *mxactFullScanLimit)
```



```c
/*
	 * We can always ignore processes running lazy vacuum.  This is because we
	 * use these values only for deciding which tuples we must keep in the
	 * tables.  Since lazy vacuum doesn't write its XID anywhere, it's safe to
	 * ignore it.  In theory it could be problematic to ignore lazy vacuums in
	 * a full vacuum, but keep in mind that only one vacuum process can be
	 * working on a particular table at any time, and that each vacuum is
	 * always an independent transaction.
	 */
	*oldestXmin =
		TransactionIdLimitedForOldSnapshots(GetOldestXmin(rel, PROCARRAY_FLAGS_VACUUM), rel);

	Assert(TransactionIdIsNormal(*oldestXmin));
```



```c
/*
	 * Compute the cutoff XID, being careful not to generate a "permanent" XID
	 */
	limit = *oldestXmin - freezemin;
	if (!TransactionIdIsNormal(limit))
		limit = FirstNormalTransactionId;

	/*
	 * If oldestXmin is very far back (in practice, more than
	 * autovacuum_freeze_max_age / 2 XIDs old), complain and force a minimum
	 * freeze age of zero.
	 */
	safeLimit = ReadNewTransactionId() - autovacuum_freeze_max_age;
	if (!TransactionIdIsNormal(safeLimit))
		safeLimit = FirstNormalTransactionId;

	if (TransactionIdPrecedes(limit, safeLimit))
	{
		ereport(WARNING,
				(errmsg("oldest xmin is far in the past"),
				 errhint("Close open transactions soon to avoid wraparound problems.")));
		limit = *oldestXmin;
	}

	*freezeLimit = limit;
```



GetNewTransactionId()中, 如果clog等需要扩展, 则扩展之.

```c
/*
	 * If we are allocating the first XID of a new page of the commit log,
	 * zero out that commit-log page before returning. We must do this while
	 * holding XidGenLock, else another xact could acquire and commit a later
	 * XID before we zero the page.  Fortunately, a page of the commit log
	 * holds 32K or more transactions, so we don't have to do this very often.
	 *
	 * Extend ux_subtrans and ux_commit_ts too.
	 */
	ExtendCLOG(xid);
	ExtendCommitTs(xid);
	ExtendSUBTRANS(xid);
```



## 引用文档

论Postgresql长事务数据膨胀的优化.docx   张震阳

