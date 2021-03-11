# PgSQL · 特性分析 · 谈谈checkpoint的调度 学习笔记

by 刘海峰 2021.01.22

http://mysql.taobao.org/monthly/2015/09/06/



真正将脏页回写到磁盘的操作，是由checkpointer进程完成的。

pendingOpsTable存放了所有write过的脏页，包括之前background writer已经处理的脏页。

随后PG的checkpointer进程会根据pedingOpsTable的记录，进行脏页回写操作

如果我们放慢checkpoint的频率，多个随机页面就有可能组成一次顺序批量写入，效率大大提高。

另外，checkpoint会进行fsync操作，大量的fsync可能造成系统IO阻塞，降低系统稳定性，因此checkpoint不能过于频繁。

但checkpoint的间隔也不能无限制放大。因为如果出现系统宕机，在进行恢复时，需要从上一次checkpoint的时间点开始恢复，如果checkpoint间隔过长，会造成恢复时间缓慢，降低可用性。

用户有可能反复修改相同的页面，脏页不多，但实际修改量很大，这时候也是应该尽快进行checkpoint，减少恢复时间的。

这些request最终会被checkpointer进程读取，放入`pendingOpsTable`，而真正将脏页回写到磁盘的操作，是由checkpointer进程完成的。

checkpointer每次也会调用smgrwrite，把所有的shared buffers脏页（即还没有被background writer清理过得脏页）写入操作系统的page cache，并存入`pendingOpsTable`。

而通过记录WAL日志的产生量，可以很好的评估这个修改量，所以就有了`checkpoint_segments`这个参数，它用于指定产生多少WAL日志后，进行一次checkpoint。

**checkpoint_segments 在PG10中是 CheckPointSegments 参数.**

`checkpoint_completion_target`直接控制了checkpoint中的write脏页的速度，使其完成时新产生日志文件数为上述期望值。

当脏页全部被write完，就要进行真正的磁盘操作了，即fsync。

> 将OS cache中的数据刷到磁盘上.

以上便是checkpoint的调度机制。我们要注意调整上述几个参数时，不要让checkpoint产生过于频繁，否则频繁的fsync操作会是系统不稳定。