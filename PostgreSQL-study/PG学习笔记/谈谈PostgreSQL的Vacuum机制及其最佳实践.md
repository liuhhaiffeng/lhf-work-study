# 谈谈PostgreSQL的Vacuum机制及其最佳实践

by 刘海峰整理和批注  2020.1.5



## 引言

◆◆

因为多数有事务的数据库都是有回滚段的，所以大家对于PostgreSQL中没有回滚段表示很诧异，PostgreSQL中的vacuum在对旧版本数据做清理时会占用一些IO而对业务可能会产生一些负面影响，这些负面影响在口口相传中会被放大。而在笔者的最佳实践中这个问题并没有网上传的那么严重。

实际上PostgreSQL数据库没有回滚段的设计是比较有创意的地方，但一些人也认为这是有争议的地方，笔者以前是Oracle DBA，也熟悉MySQL数据库，所以试图最佳实践的角度和从原理上把有回滚段和没有回滚的好处和坏处和大家讲清楚。

◆◆

## 无回滚段的争议

◆◆

很多人会认为PostgreSQL中无回滚段是一个很大的缺陷，如文章新特性：postgresql的vacuum漫谈，会认为PostgreSQL中无回滚段就是一个缺陷，同时埋怨PG内核社区的人为什么还不赶紧把这个功能加上去，如这篇文章的作者说：要从本质上解决这个问题,是需要官方来进行发行版的版本增强,而非依赖外部工具修修补补”

注：这篇文章在方方面面写的还是很全的，一些地方的思考也是很到位的，这篇文章的作者把一些东西写的也比较深入。

很多人在读了这些vacuum的文章，可能都会在潜意识中把vacuum的负作用放大，**实际上PG内核开发人员没有把回滚段加上是有原因的，**因为回滚段这个事情是有两面性的，目前PG这样没有回滚段时，虽然看起来好象需要vacuum做清理，好象会多产生一些IO，会产生很多负面的影响，实际上这种方式产生的IO与回滚段在理论上是差不多的，同时这种方式也有很多好处。

> lhf: vacuum和回滚段均会产生IO, 并且回滚段的回滚操作本身, 也会产生大量的redo log, 其对IO也会产生冲击. 
>
> 另外, vacuum清理不及时, 导致deadtuple过多, 也会影响顺序扫描的性能, 但在实际生产中个人认为此问题几乎不存在, 一方面vacuum的清理比较及时, 另一方面多数数据库都有索引机制, 顺序扫描查询数据很少.

使用回滚段后，虽然解决了一些问题，但也会带来一些棘手的问题。例如我们知道Oracle中使用了回滚段，如Oracle数据库宕机时如果有很多事务正在运行，这时数据库再启动后，需要把之前的事务做回滚，当没有回滚完成时，数据行上仍然有锁的，这时业务仍然不能正常操作，如果恰好碰到要回滚一些很大的事务，情况会更坏。而PG因为没有回滚段，异常宕机后，启动后可以很快进入正常工作的状态。

> lhf: PG有所谓的瞬间恢复的特性或优点.

明显在出现数据库宕机这种出故障之后，每个人都希望数据库能尽快恢复正常，但这种回滚段的机制导致数据库宕机后的恢复正常工作的时间变长。同时需要记住回滚操作本身，也会产生大量的redo log，对IO也会产生冲击。所以在oracle数据库中这种使用了固定空间的回滚段，如果无经验的DBA导致配置不合理，当有大量的并发事务操作时回滚段中的旧数据来不及回收，导致回滚段满了，就会导致数据库的所有更新操作都被hang住，出现这种情况的概率在Oracle领域其实也并不低。

> lhf: 回滚段满了, 数据库会hang住, vacuum清理(如: 事务回收)不及时的话, 数据库也会hang住.

**所以PG内核社区对于是否需要加上回滚段的功能，一直是有争议的，原因就是在于使用回滚段，看起来美好，但也存在另外一些麻烦的事情。**

所以实际上回滚段是把旧版本集中放到一个地方集中处理，这个集中进行垃圾回收，虽然处理效率高一些，但“集中”就意味竞争更激烈，系统可能更不稳定，而集中处理通常也是会占用IO，只是PG的回收操作发生在数据文件，而其它数据库发生在回滚段。而象PG这样把旧版本放在原先的数据文件中，并没有集中到回滚段中，相对来说，竞争就没有这么激烈。

> lhf: 回滚段是"集中式"的垃圾回收, PG是分散式的垃圾回收, 分散式的在集群环境中, 竞争没有那么激烈.

同时因为MVCC的事务机制，回滚段中的数据虽然是旧版本数据，但仍然不能丢失，当回滚段损坏，就会导致数据库起不来，所以从工程实践上来看，回滚段的机制在一定的程度上会降低数据库的可靠性。在Oracle中的一些掉电故障后起不来的情况，多数原因是因为回滚段中有数据丢失或损坏。

> lhf: MVCC的缘故, 旧版本数据仍然不能丢失, Oracle是放在回滚段中的, 而PG是和正常数据同等对待---放在数据文件中的, 从工程实践角度, PG的做法较为可靠一些.

有人可能会问，**为什么MySQL使用了回滚段，但没有感觉出回滚段的坏处？**原因是MySQL不太能支持单实例大数据库，在MySQL单实例上通常没有这么大的事务并发（注意是TPS，还不是QPS），而在PG和Oracle中有很多5T以上的大数据库存在，也有很多大事务并发的数据库。而MySQL通常都是分库分表，经过分库分表之后单个实例并不大，在生产中MySQL大于1T的数据库比较少。所以，MySQL如果有一些大于5T的数据库，同时事务并发又高，那么回滚段的问题也会出现。

> lhf: 同样, 对于PG, 表不能太大。有一些用户的一张表到达了好几十GB甚至上百GB， 这时vacuum整理这样的一张表有可能一天都没有整理完，这样就出问题了。所以对于大表来说需要做成分区表，一般表的记录超过3000万，就应该建成分区表。

其实对于回滚段的机制，只是第一眼看上去好象比PG目前这种没有回滚段的设计好一些，但真的这么做了，是否好就不一定了。因为你放到回滚段中，实际上旧版本的数据也是要清理的，只是在回滚段中需要集中清理，而在pg中，是分散到各个数据文件中去清理。而在PG中每次做vacuum中，并不需要把数据文件全部扫描，一些没有发生变化的数据块，并不需要去扫描。所以很多时候，第一次做vacuum时会慢很多，原因是需要清理的垃圾数据很多，但第二次和第三次会快很多，就是这个原因。

> lhf: PG有VM表, VM表中对全可见的数据块, 即没有发生变化的数据块并不进行扫描.

◆◆

## Vacuum的一些最佳实践

◆◆

笔者认为主要是用户对PostgreSQL的一些vacuum的配置参数及相应的机制不太了解，导致了很多vaccum的问题出现。我们需要根据实际情况对vacuum这些参数进行一些调整。

PostgreSQL中的一些vacuum参数是按照原先的机械硬盘配置的，这些参数都有一些保守，如vacuum_cost_limit默认值为200，通常太小了，对于有cache的raid卡，这个值应该设置成1000左右，对于ssd，应该设置成10000。很多一些用户就是因为这个参数设置的太小，导致一些用户旧版本数据没有得到及时清理，导致数据库的年龄不断增加，当离20亿还有100万时，PostgreSQL为了安全，就会主动宕下来。

> lhf: 在执行 `VACUUM` 和 `ANYLYZE` 期间，系统会维护一个用于估算各种I/O操作所消耗的内部
> 计数器,当该值达到`vacuum_cost_limit`的值时，该进程会休眠 `vacuum_cost_delay` 指
> 定的时间，并重置计数器的值，继续运行 `VACUM` 或者 `ANYLYZE` 操作
>
> vacuum_cost_limit = 200   
>
> vacuum_cost_delay = 0  # 单位微秒，默认为 0 没有开启

autovacuum_vacuum_cost_delay的值也应该设置成10ms或更低，因为为了让系统更平稳，整理完2000个数据块后休眠20ms，不如设置成整理完1000个数据块后就休眠10ms，这样会让系统更平稳。所以正确的配置是把autovacuum_vacuum_cost_delay配置成10ms或5ms后，如果觉得vacuum影响大，应该把vacuum_cost_limit调小，而不是调整autovacuum_vacuum_cost_delay这个值。

另外，对于事务繁忙的数据库autovacuum_max_workers默认值为3，也小了一些，这个参数表示可以同发做vacuum的数目，我们可以把这个参数设置成10，这样vacuum整理就更及时了。

PostgreSQL参数autovacuum_freeze_max_age的默认值是2亿，如果我们不想让vacuum这么频繁的整理，这个参数值就有一些保守了，因为可用的是20亿，2亿就开始整理有些频繁了，这个参数可以改成5亿，有时设置成10亿也是可以的。因为每天上亿次的事务的数据库并不多，即使1天1亿个事务，10天才能用得完。这10天的时候也够vacuum把旧版本数据清理掉了。

当然如果你的数据库vacuum也没有导致出什么问题，数据库也不繁忙，autovacuum_freeze_max_age的就保持默认值2亿，这在多数的数据库也不存在问题。

**另还有一些需要注意的事，vacuum并不能在一张表上做并发整理，所以表不能太大。有一些用户的一张表到达了好几十GB甚至上百GB， 这时vacuum整理这样的一张表有可能一天都没有整理完，这样就出问题了。所以对于大表来说需要做成分区表，一般表的记录超过3000万，就应该建成分区表。**

> PG10目前vacuum lazy只能在表间并发, 不能表内并发, PG13好像可以表内并发了.

对于旧版本的PostgreSQL来说，PG是通过表的继承来实现的分区的，在10.X版本之前，建分区表的的语法不方便，导致了一些用户没有使用分区表。另外，即使是10.X之后，PG的分区表仍然是通过表继承实现的，性能会差一些，所以最佳实践是使用pg_pathman插件来实现分区表。很多人不知道pg_pathman，所以在分区表方面会遇到一些问题。

PostgreSQL对于这种无回滚段的多版本实现方式做了很多的优化，如HOT（heap only tuple）技术。我们知道PostgreSQL在做更新上，实际上是在旧行上打“删除标志”，然后插入新行。而因为新行的物理地址与原先旧行的物理地址不同，如果没有特别的方法，就需要同步更新索引（这里解释一下，我们知道索引的原理是键值和行的物理地址的对应关系，而因为新行的物理地址与旧行不一样，那么索引中记录的行的物理地址一般也需要更新）。

> lhf: 对于hot, 除过vacuum, PG还有个块内修剪(prune)的方法, 可以进一步的提升垃圾回收的效率.

当然如果更新的列是索引的键，那么不管是否是采用回滚段的机制，都需要做索引的更新，但如果更新的列与索引无关，对于有回滚段机制的数据库来说是不需要更新索引的，因为有回滚段时，更新是在原行上进行的，行的物理地址不发生变化，对于PostgreSQL来说就不行了，因为新行的物理地址发生了变化，也需要更新索引，但HOT技术可以实现在大多数情况下不需要更新索引，在HOT技术中如果新行与旧行在同一个数据块中，是不需要更新索引的，这时索引仍然指向旧行，旧行与新行之间建立了一个指针，所以虽然索引指向旧行，但索引通过旧行上的这个指针也可以访问到正确的版本数据。

但如果新行与旧行不在一个数据块中，则HOT技术不生效，这时就需要更新索引。所以在频繁更新的表时，应该设置fillfactor参数，将其设置为90%或80%等更低的值，这样在数据块中有空闲空间，这时更新非索引键时，就不会更新索引。fillfactor这个参数相关于oracle中的表的PCTFREE参数。

> [Postgresql fillfactor](https://blog.csdn.net/weixin_30697239/article/details/95837713)

有些人说，新行与旧行不在同一个数据块中，用指针也同样可以实现这个功能，为什么不做成这样呢？首先跨数据块的指针会占用更多的字节数，另跨数据块的指针也会产生更多的IO，所以PostgreSQL为了这个原因，没有做跨数据块的多版本行的指针。

PostgreSQL也实现了类似Oracle的延迟块清除工作，如果一个数据块被读上来的时候，做多版本判断时发现其中的行的事务都是提交的，会给行设置一个标志位，这个标志位表示这个行一定是可见的，以后不需要再到commit log中去查看其事务状态了。所以PostgreSQL与Oracle数据库一样，一些select操作也会产生一些写IO。另当更新数据马上提交后，脏页还在内存中时，PostgreSQL会把这些脏页上的行也设置上这个标志，这样这个数据块今后刷新到磁盘中后也不需要做vacuum了。

> lhf: 思考: PG在select时也会产生wal吗, 有什么条件?



from   https://www.sohu.com/a/288101133_505827

## 备注参考文档

[PostgreSQL中 Vacuum 略谈](https://blog.csdn.net/yaoqiancuo3276/article/details/80376540)

### vacuum的功能

[PostgreSQL vacuum原理一功能与参数](https://blog.csdn.net/wzyzzu/article/details/50426628)

### vacuum参数介绍

[PostgreSQL vacuum原理一功能与参数](https://blog.csdn.net/wzyzzu/article/details/50426628)