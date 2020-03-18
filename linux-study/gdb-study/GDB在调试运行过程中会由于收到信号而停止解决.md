# GDB在调试运行过程中会由于收到信号而停止

原创阿威_t 最后发布于2015-07-06 14:03:25 阅读数 1374  收藏
展开
GDB在调试运行过程中会由于收到信号而停止，可以输入命令info signals或 info handle
 
```sh
 
(gdb) info signals
 
Signal        Stop      Print   Pass to program Description
 
SIGABRT       Yes       Yes     Yes             Aborted
SIGEMT        Yes       Yes     Yes             Emulation trap
SIGFPE        Yes       Yes     Yes             Arithmetic exception
SIGKILL       Yes       Yes     Yes             Killed
SIGBUS        Yes       Yes     Yes             Bus error
SIGSEGV       Yes       Yes     Yes             Segmentation fault
SIGPIPE       Yes       Yes     Yes             Broken pipe
SIGTERM       Yes       Yes     Yes             Terminated
SIGURG        No        No      Yes             Urgent I/O condition
SIGSTOP       Yes       Yes     Yes             Stopped (signal)
SIGIO         No        No      Yes             I/O possible
```

我调试时SIGPIPE老是导致暂停，这个是由于Socket引起的。我不想GDB因为这个问题停止，可以关闭它。使用handle命令。

```sh
handle SIGPIPE nostop
```

如果连提示信息都不想看见，就可以这样设置:

```sh
 handle SIGPIPE nostop noprint
 ```
 
————————————————
版权声明：本文为CSDN博主「阿威_t」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/pro_technician/article/details/46773355