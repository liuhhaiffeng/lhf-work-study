list_for_each()与list_for_each_safe()的区别

原创Choice_JJ 最后发布于2012-04-25 10:33:21 阅读数 24669 收藏

展开

list_for_each()的定义：

/\*\*

\* list_for_each - iterate over a list

\* \@pos: the &struct list_head to use as a loop counter.

\* \@head: the head for your list.

\*/

\#define list_for_each(pos, head) \\

for (pos = (head)-\>next, prefetch(pos-\>next); pos != (head); \\

pos = pos-\>next, prefetch(pos-\>next))

list_for_each_safe()的定义：

/\*\*

\* list_for_each_safe - iterate over a list safe against removal of list entry

\* \@pos: the &struct list_head to use as a loop counter.

\* \@n: another &struct list_head to use as temporary storage

\* \@head: the head for your list.

\*/

\#define list_for_each_safe(pos, n, head) \\

for (pos = (head)-\>next, n = pos-\>next; pos != (head); \\

pos = n, n = pos-\>next)

由上面两个对比来看，list_for_each_safe()函数比list_for_each()多了一个中间变量n

当在遍历的过程中需要删除结点时，来看一下会出现什么情况：

list_for_each()：list_del(pos)将pos的前后指针指向undefined state，导致kernel
panic，list_del_init(pos)将pos前后指针指向自身，导                            
致死循环。

list_for_each_safe()：首先将pos的后指针缓存到n，处理一个流程后再赋回pos，避免了这种情况发生。

因此之遍历链表不删除结点时，可以使用list_for_each()，而当由删除结点操作时，则要使用list_for_each_safe()。

其他带safe的处理也是基于这个原因。

关于kernel panic:

它表示linux
kernel走到了一个不知道怎么走下一步的状况，一旦出现这个情况，kernel就尽可能把它此时能获取的全部信息打印出来，至于能打印出多少信息，那就看哪种情况导致它panic了。

有两种主要类型的kernel panic：hard panic（也就是Aieee信息输出），soft
panic（也就是Oops信息输出）

什么能导致kernel panic：

只有加载到内核空间的驱动模块才能直接导致kernel
panic，可以在系统正常的情况下，使用lsmod查看当前系统加载了哪些模块。除此之外，内建在内核里的组建（比如memory
map等）也能导致panic。

详细的就不说了。

————————————————

版权声明：本文为CSDN博主「Choice_JJ」的原创文章，遵循 CC 4.0 BY-SA
版权协议，转载请附上原文出处链接及本声明。

原文链接：https://blog.csdn.net/choice_jj/article/details/7496732
