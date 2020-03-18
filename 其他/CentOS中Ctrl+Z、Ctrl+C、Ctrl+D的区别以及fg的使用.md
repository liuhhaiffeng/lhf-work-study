## CentOS中Ctrl+Z、Ctrl+C、Ctrl+D的区别

Ctrl+C和Ctrl+Z都是中断命令，但作用不同。

　　Ctrl+C是发送SIGINT信号，终止一个进程。

　　Ctrl+Z是发送SIGSTOP信号，挂起一个进程，将作业放置到后台（暂停状态）。与此同时，可以通过fg重启前台被中断的任务，也可以通过bg把中断的任务放到后台执行。

　　Ctrl+D表示一个特殊的二进制值EOF，代表输入完成或注销。

转载于:https://www.cnblogs.com/diantong/p/5566305.html

### SIGINT、SIGQUIT、 SIGTERM、SIGSTOP区别

https://blog.csdn.net/pmt123456/article/details/53544295

转载pmt123456 最后发布于2016-12-09 21:22:20 阅读数 20282  收藏
展开
2) SIGINT
程序终止(interrupt)信号, 在用户键入INTR字符(通常是Ctrl-C)时发出，用于通知前台进程组终止进程。


3) SIGQUIT
和SIGINT类似, 但由QUIT字符(通常是Ctrl-\)来控制. 进程在因收到SIGQUIT退出时会产生core文件, 在这个意义上类似于一个程序错误信号。


15) SIGTERM
程序结束(terminate)信号, 与SIGKILL不同的是该信号可以被阻塞和处理。通常用来要求程序自己正常退出，shell命令kill缺省产生这个信号。如果进程终止不了，我们才会尝试SIGKILL。


19) SIGSTOP
停止(stopped)进程的执行. 注意它和terminate以及interrupt的区别:该进程还未结束, 只是暂停执行. 本信号不能被阻塞, 处理或忽略.

### SIGTSTP和SIGSTOP的区别

https://blog.csdn.net/shandianling/article/details/17032607?depth_1-utm_source=distribute.pc_relevant.none-task&utm_source=distribute.pc_relevant.none-task

 SIGTSTP与SIGSTOP都是使进程暂停（都使用SIGCONT让进程重新激活）。唯一的区别是SIGSTOP不可以捕获。

捕捉SIGTSTP后一般处理如下：

1）处理完额外的事

2）恢复默认处理

3）发送SIGTSTP信号给自己。（使进程进入suspend状态。）