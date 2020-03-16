用Valgrind定位子进程内存泄漏
动静之逸关注
0.1682018.09.17 17:29:19字数 257阅读 1,336
1. valgrind跟踪子进程
以下例子用spawn-cgi来测试验证，spawn-cgi会生成一个cgi子进程
--trace-children=yes：valgrind加上该参数用于跟踪子进程
valgrind --leak-check=full --trace-children=yes --tool=memcheck --log-file=a.log spawn-fcgi -a 127.0.0.1 -p 8088 -F 1 -f fastcgi
2. 如何生成报告
跟踪子进程后，valgrind变成服务后台运行了，正常在终端生成报告只需要按ctrl-c即可，如果是调试子进程，那么可以模拟ctrl-c，发送给对应的valgrind服务进程，ctrl-c对应的信号为SIGINT，valgrind会捕捉该信号，并生成报告，命令如下：
kill -s SIGINT pid
3. 查看报告
这步就不用多说了，直接打开a.log，查看definitely lost对应的地方即可，需要分析是否真为内存泄漏，还是只是分配一次性的内存，这就和程序的具体逻辑相关了

来自 <https://www.jianshu.com/p/d85bd1ef8f45> 
