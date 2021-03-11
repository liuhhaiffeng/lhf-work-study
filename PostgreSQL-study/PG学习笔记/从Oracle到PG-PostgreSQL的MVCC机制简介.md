## [从Oracle到PG-*PostgreSQL*的MVCC机制简介](https://zhuanlan.zhihu.com/p/109266113)

[![bluesky](https://pic2.zhimg.com/50/v2-743a74801f68597ceaa26b462ba675f6_s.jpg?source=4e949a73)](https://www.zhihu.com/people/bluesky-85-21)

[bluesky](https://www.zhihu.com/people/bluesky-85-21)

软件架构师

PostgreSQL和Oracle、MySQL等RDBMS一样，都有自己的并发控制机制。而并发控制的目的是为了在多个事务同时运行时保持事务ACID属性。
MVCC即Multi-version concurrence control首字母缩写，MVCC会为每个数据更改操作创建数据块或数据行的新版本，同时保留旧版本，主要优点是：
‘readers don’t block writers,and writers don’t block readers’
即“读不会阻塞写，而写也不会阻塞读”。
在Oracle中，多版本控制MVCC通过回滚段实现，当行记录row发生更改的时候，先将数据块的旧版本将写入回滚段，随后将新数据覆写入原data block数据块区域。在读取数据的时候，通过比对scn来读取合适的数据版本。

![img](https://pic1.zhimg.com/v2-06acd86aa596ae7b447410ff8c0d3ce8_b.jpg)


Oracle 19C Read Consistency in the Read Committed

相对Oracle来说，PostgreSQL的MVCC则使用更简单的方法来实现。当行记录tuple发生更改时候，新数据直接插入到原来的data page中。在读取数据的时候，PostgreSQL通过可见性规则读取合适的数据版本。

![img](https://pic2.zhimg.com/v2-ff8fa05cd1a8ac439a556423084b5d41_b.jpg)


Transaction ids in PostgreSQL

简单来说，PostgreSQL和Oracle在MVCC的实现上存在以下主要区别：
**Oracle：**基于SCN，块级别，循环undo segment实现，支持闪回功能，存在大事务回滚、快照过旧ORA-01555问题。
**PostgreSQL：**基于事务编号txid，行级别，无需undo，不支持闪回，大事务可瞬间回滚，存在数据块（block page）空间及性能消耗问题。

值得提出的是，去年Oracle中出现的SCN最大值预警问题，在PostgreSQL中通过txid循环复用来规避。
Oracle查看当前scn:
SQL> select current_scn from v$database;
CURRENT_SCN
\--------------------
698823298
SQL>

PostgreSQL查看当前事务ID：
(postgres@[local]:5432)[akendb01]#select txid_current();
txid_current
\--------------
636
(1 row)

–查看行记录tuple 1的txid：
(postgres@[local]:5432)[akendb01]#insert into table01 values(1,'aken01');
INSERT 0 1
(postgres@[local]:5432)[akendb01]#select id,name, ctid,xmin,xmax from public.table01;
id | name | ctid | xmin | xmax
----+--------+-------+------+------
1 | aken01 | (0,1) | 636 | 0

上面的行记录Tuple 1，即id=1的事务ID如下:

- **t_xmin：**被设置为636，表示该tuple的版本在txid=636的事务中被插入。
- **t_xmax** ：被设置为 0，表示该tuple的版本未发生过deleted or updated.
- **t_ctid：**被设置为（0.1），表示该tuple位于page 0的存储位置。这里的t_ctid和Oracle的rowid相似。

–下面对行记录tuple进行更改：
(postgres@[local]:5432)[akendb01]#insert into table01 values(2,'aken02');
INSERT 0 1
(postgres@[local]:5432)[akendb01]#update table01 set name='aken03' where id=2;
UPDATE 1

–查看tuple 2的事务txid：
(postgres@[local]:5432)[akendb01]#select id,name, ctid,xmin,xmax from public.table01;
id | name | ctid | xmin | xmax
----+--------+-------+------+------
1 | aken01 | (0,1) | 636 | 0
2 | aken02 | (0,2) | 638 | 639
2 | aken03 | (0,2) | 639 | 0
(3 rows)
(postgres@[local]:5432)[akendb01]#

上面的行记录Tuple 2，即id=2的事务ID如下:
**版本1：旧版本：**

- **t_xmin：**被设置为638，表示该tuple的版本在txid=638的事务中被插入。
- **t_xmax** ：被设置为 639，表示该tuple的版本发生了deleted or updated，为旧版本.
- **t_ctid：**被设置为（0.2），表示该tuple位于page 0的位置。这里的t_ctid和Oracle的rowid相似。

**版本2：新版本：**

- **t_xmin：**被设置为639，表示该tuple的版本在txid=639的事务中被插入。
- **t_xmax** ：被设置为0，表示该tuple的版本未发生过deleted or updated.
- **t_ctid：**被设置为（0.2），表示该tuple位于page 0的位置。这里的t_ctid和Oracle的rowid相似。

欢迎关注头条号查看Aken更多相关文章：
[https://www.toutiao.com/c/user/54536888148/#mid=1610143870006285](https://link.zhihu.com/?target=https%3A//www.toutiao.com/c/user/54536888148/%23mid%3D1610143870006285)
参考资料：
[https://www.postgresql.org/docs/12/mvcc.html](https://link.zhihu.com/?target=https%3A//www.postgresql.org/docs/12/mvcc.html)
[https://docs.oracle.com/en/database/oracle/oracle-database/19/cncpt](https://link.zhihu.com/?target=https%3A//docs.oracle.com/en/database/oracle/oracle-database/19/cncpt)
[http://www.interdb.jp/pg/pgsql05.html](https://link.zhihu.com/?target=http%3A//www.interdb.jp/pg/pgsql05.html)
—本文完—

[发布于 2020-02-26](https://zhuanlan.zhihu.com/p/109266113)