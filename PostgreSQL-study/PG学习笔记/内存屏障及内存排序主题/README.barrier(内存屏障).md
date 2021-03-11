Memory Barriers
===============

Modern CPUs make extensive use of pipe-lining and out-of-order execution,
meaning that the CPU is often executing more than one instruction at a
time, and not necessarily in the order that the source code would suggest.
Furthermore, even before the CPU gets a chance to reorder operations, the
compiler may (and often does) reorganize the code for greater efficiency,
particularly at higher optimization levels.  Optimizing compilers and
out-of-order execution are both critical for good performance, but they
can lead to surprising results when multiple processes access the same
memory space.

Example
=======

Suppose x is a pointer to a structure stored in shared memory, and that the
entire structure has been initialized to zero bytes.  One backend executes
the following code fragment:

    x->foo = 1;
    x->bar = 1;

Meanwhile, at approximately the same time, another backend executes this
code fragment:

    bar = x->bar;
    foo = x->foo;

The second backend might end up with foo = 1 and bar = 1 (if it executes
both statements after the first backend), or with foo = 0 and bar = 0 (if
it executes both statements before the first backend), or with foo = 1 and
bar = 0 (if the first backend executes the first statement, the second
backend executes both statements, and then the first backend executes the
second statement).

Surprisingly, however, the second backend could also end up with foo = 0
and bar = 1.  The compiler might swap the order of the two stores performed
by the first backend, or the two loads performed by the second backend.
Even if it doesn't, on a machine with weak memory ordering (such as PowerPC
or Itanium) the CPU might choose to execute either the loads or the stores
out of order.  This surprising result can lead to bugs.
在多进程或多线程的并发情况下, 上述"赋值"和"读值"不但可能出现问题, 并且由于"内存排序"的
情况, 还会出现更加意想不到的结果.

A common pattern where this actually does result in a bug is when adding items
onto a queue.  The writer does this:

    q->items[q->num_items] = new_item;
    ++q->num_items;

The reader does this:

    num_items = q->num_items;
    for (i = 0; i < num_items; ++i)
        /* do something with q->items[i] */

This code turns out to be unsafe, because the writer might increment
q->num_items before it finishes storing the new item into the appropriate slot.
More subtly, the reader might prefetch the contents of the q->items array
before reading q->num_items.  Thus, there's still a bug here *even if the
writer does everything in the order we expect*.  We need the writer to update
the array before bumping the item counter, and the reader to examine the item
counter before examining the array.
解释一下: 

    q->items[q->num_items] = new_item;
    ++q->num_items;
    
    在编译器优化后, 可能会这样执行:
    tmp_num_items = q->num_items;
    ++q->num_items;
    q->items[tmp_num_items] = new_item;


    num_items = q->num_items;
    for (i = 0; i < num_items; ++i)
        /* do something with q->items[i] */
    
    在编译器优化后, 可能会这样执行:
    tmp_num_items = q->num_items;   /* tmp_num_items 可能是writer中++之前的值 */
    for (i = 0; i < tmp_num_items; ++i)
    { }
    num_items = q->num_items;       /* 这时候, q->num_items 的值在writer中可能已经++了, num_items可能在
                                       后面的逻辑中有用, 但在for()中没有及时用到
                                     */

说明: 在非并发情况下, CPU认为(上述自己搞的(为了提升性能的)内存重排序, 是完全没有问题的, 也没有任何的副作用,
     所以它自然就认为可以"内存重排序", 而在并发下, 就会出现各种意想不到的情况.



Note that these types of highly counterintuitive bugs can *only* occur when
multiple processes are interacting with the same memory segment.  A given
process always perceives its *own* writes to memory in program order.

Avoiding Memory Ordering Bugs
=============================

The simplest (and often best) way to avoid memory ordering bugs is to
protect the data structures involved with an lwlock.  For more details, see
src/backend/storage/lmgr/README.  For instance, in the above example, the
writer could acquire an lwlock in exclusive mode before appending to the
queue, and each reader could acquire the same lock in shared mode before
reading it.  If the data structure is not heavily trafficked, this solution is
generally entirely adequate.

However, in some cases, it is desirable to avoid the overhead of acquiring
and releasing locks.  In this case, memory barriers may be used to ensure
that the apparent order of execution is as the programmer desires.   In
PostgreSQL backend code, the pg_memory_barrier() macro may be used to achieve
this result.  In the example above, we can prevent the reader from seeing a
garbage value by having the writer do this:

    q->items[q->num_items] = new_item;
    pg_memory_barrier();
    ++q->num_items;

添加内存屏障标志, 告诉编译器上述两个语句的顺序不能交换.

And by having the reader do this:

    num_items = q->num_items;
    pg_memory_barrier();
    for (i = 0; i < num_items; ++i)
        /* do something with q->items[i] */

添加内存屏障标志, 告诉编译器上述每个语句的顺序不能交换. 注意: 即使这里for()看起来是一个"复合语句",
这里也要将其当做一个单个语句来对待.

The pg_memory_barrier() macro will (1) prevent the compiler from rearranging
the code in such a way as to allow the memory accesses to occur out of order
and (2) generate any code (often, inline assembly) that is needed to prevent
the CPU from executing the memory accesses out of order.  Specifically, the
barrier prevents loads and stores written after the barrier from being
performed before the barrier, and vice-versa.

Although this code will work, it is needlessly inefficient.  On systems with
strong memory ordering (such as x86), the CPU never reorders loads with other
loads, nor stores with other stores.  It can, however, allow a load to
performed before a subsequent store.  To avoid emitting unnecessary memory
instructions, we provide two additional primitives: pg_read_barrier(), and
pg_write_barrier().  When a memory barrier is being used to separate two
loads(读), use pg_read_barrier(); when it is separating two stores(写), use
pg_write_barrier(); when it is a separating a load and a store (in either
order), use pg_memory_barrier().  pg_memory_barrier() can always substitute
for either a read or a write barrier, but is typically more expensive, and
therefore should be used only when needed.

With these guidelines in mind, the writer can do this:

    q->items[q->num_items] = new_item;
    pg_write_barrier();
    ++q->num_items;

And the reader can do this:

    num_items = q->num_items;
    pg_read_barrier();
    for (i = 0; i < num_items; ++i)
        /* do something with q->items[i] */

On machines with strong memory ordering, these weaker barriers will simply
prevent compiler rearrangement, without emitting any actual machine code.
On machines with weak memory ordering, they will prevent compiler
reordering and also emit whatever hardware barrier may be required.  Even
on machines with weak memory ordering, a read or write barrier may be able
to use a less expensive instruction than a full barrier.

Weaknesses of Memory Barriers
=============================

While memory barriers are a powerful tool, and much cheaper than locks, they
are also much less capable than locks.  Here are some of the problems.

1. Concurrent writers are unsafe.  In the above example of a queue, using
memory barriers doesn't make it safe for two processes to add items to the
same queue at the same time.  If more than one process can write to the queue,
a spinlock or lwlock must be used to synchronize access. The readers can
perhaps proceed without any lock, but the writers may not.

Even very simple write operations often require additional synchronization.
For example, it's not safe for multiple writers to simultaneously execute
this code (supposing x is a pointer into shared memory):

    x->foo++;

Although this may compile down to a single machine-language instruction,
the CPU will execute that instruction by reading the current value of foo,
adding one to it, and then storing the result back to the original address.
If two CPUs try to do this simultaneously, both may do their reads before
either one does their writes.  Eventually we might be able to use an atomic
fetch-and-add instruction for this specific case on architectures that support
it, but we can't rely on that being available everywhere, and we currently
have no support for it at all.  Use a lock.

2. Eight-byte loads and stores aren't necessarily atomic.  We assume in
various places in the source code that an aligned four-byte load or store is
atomic, and that other processes therefore won't see a half-set value.
Sadly, the same can't be said for eight-byte value: on some platforms, an
aligned eight-byte load or store will generate two four-byte operations.  If
you need an atomic eight-byte read or write, you must make it atomic with a
lock.

3. No ordering guarantees.  While memory barriers ensure that any given
process performs loads and stores to shared memory in order, they don't
guarantee synchronization.  In the queue example above, we can use memory
barriers to be sure that readers won't see garbage, but there's nothing to
say whether a given reader will run before or after a given writer.  If this
matters in a given situation, some other mechanism must be used instead of
or in addition to memory barriers.

4. Barrier proliferation.  Many algorithms that at first seem appealing
require multiple barriers.  If the number of barriers required is more than
one or two, you may be better off just using a lock.  Keep in mind that, on
some platforms, a barrier may be implemented by acquiring and releasing a
backend-private spinlock.  This may be better than a centralized lock under
contention, but it may also be slower in the uncontended case.

结论: 通过本章的阐述, 说明了在并发情况下, 无论读操作和写操作都需要加锁(或使用内存屏障机制),
否则, 可能会出现意想不到的结果.

另外, 感觉文章中举出的例子不太好理解, 如下:

    num_items = q->num_items;
    pg_read_barrier();
    for (i = 0; i < num_items; ++i)
        /* do something with q->items[i] */
    
    文中说, 如果发生内存排序, 可能会出现, 先执行 for () { q->items[i] }, 然后才执行
    num_items = q->num_items; 这个没有理解.
    个人理解如下, 编译器在优化时, 可能会这样干:
    for (i = 0; i < q->num_items; ++i)
        /* do something with q->items[i] */
    num_items = q->num_items;
    
    即 1. 将for()中的num_items替换为q->num_items, 在for() 执行完后, 才执行num_items = q->num_items;
    这个就比较好理解了, 但不知道是否如此.

Further Reading
===============

Much of the documentation about memory barriers appears to be quite
Linux-specific.  The following papers may be helpful:

Memory Ordering in Modern Microprocessors, by Paul E. McKenney
* http://www.rdrop.com/users/paulmck/scalability/paper/ordering.2007.09.19a.pdf

Memory Barriers: a Hardware View for Software Hackers, by Paul E. McKenney
* http://www.rdrop.com/users/paulmck/scalability/paper/whymb.2010.06.07c.pdf

The Linux kernel also has some useful documentation on this topic.  Start
with Documentation/memory-barriers.txt

### 参考文档: 

[何为内存重排序？](https://www.cnblogs.com/CreateMyself/p/12485743.html)