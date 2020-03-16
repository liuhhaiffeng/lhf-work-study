linux 调试利器gdb, strace, pstack, gstack, pstree, lsof
原创mimisn 最后发布于2019-07-02 14:58:07 阅读数 107  收藏
展开
一、lsof命令
lsof（list open files）是一个查看当前系统文件的工具。在linux环境下，任何事物都以文件的形式存在，通过文件不仅仅可以访问常规数据，还可以访问网络连接和硬件。如传输控制协议 (TCP) 和用户数据报协议 (UDP) 套接字等，系统在后台都为该应用程序分配了一个文件描述符，该文件描述符提供了大量关于这个应用程序本身的信息。

1、安装lsof
centos：

yum install lsof
1
ubuntu:

sudo apt-get install lsof
1
2、lsof 参数
默认 : 没有选项，lsof列出活跃进程的所有打开文件
-a : 结果进行“与”运算（而不是“或”）
-b: 避免避免内核模块
-c ：查看指定的命令正在使用的文件和网络连接（lsof -c ls）
-p : 查看指定进程ID已打开的内容
-P: 不解析端口号
-t: 选项只返回PID
+d <目录> : 输出目录及目录下被打开的文件和目录(不递归)
+D <目录>: 递归输出及目录下被打开的文件和目录
-i <条件>: 输出符合条件与网络相关的文件
-u : 输出指定用户打开的文件
-U: 输出打开的 UNIX domain socket 文件
-n：不解析主机名
-h: 显示帮助信息
-v: 显示版本信息
3、lsof 例子
3.1、 使用<-i>显示所有连接
语法: lsof -i [4|6] [protocol][@hostname|hostaddr][:service|port]

[root@centos fd]# lsof -i
COMMAND      PID    USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
sshd        9251    root    3u  IPv4    45664      0t0  TCP *:ssh (LISTEN)
sshd        9251    root    4u  IPv6    45666      0t0  TCP *:ssh (LISTEN)
tp_web      9274    root    5u  IPv4    48424      0t0  TCP *:7190 (LISTEN)
master      9346    root   13u  IPv4    47282      0t0  TCP localhost:smtp (LISTEN)
master      9346    root   14u  IPv6    47283      0t0  TCP localhost:smtp (LISTEN)
1
2
3
4
5
6
7
3.2 、使用<-i 6>
[root@centos fd]# lsof -i 6
COMMAND    PID   USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
sshd      9251   root    4u  IPv6    45666      0t0  TCP *:ssh (LISTEN)
master    9346   root   14u  IPv6    47283      0t0  TCP localhost:smtp (LISTEN)
java     85303   root   20u  IPv6 15427459      0t0  TCP *:radan-http (LISTEN)
sshd     98855   root    8u  IPv6 20205457      0t0  TCP localhost:x11-ssh-offset (LISTEN)
sshd     98855   root   11u  IPv6 21529641      0t0  TCP localhost:6011 (LISTEN)
1
2
3
4
5
6
7
3.3、显示TCP连接
[root@centos fd]# lsof -i TCP
COMMAND      PID    USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
sshd        9251    root    3u  IPv4    45664      0t0  TCP *:ssh (LISTEN)
sshd        9251    root    4u  IPv6    45666      0t0  TCP *:ssh (LISTEN)
tp_web      9274    root    5u  IPv4    48424      0t0  TCP *:7190 (LISTEN)
master      9346    root   13u  IPv4    47282      0t0  TCP localhost:smtp (LISTEN)
master      9346    root   14u  IPv6    47283      0t0  TCP localhost:smtp (LISTEN)
tp_core     9539    root    6u  IPv4    47433      0t0  TCP localhost:52080 (LISTEN)
tp_core     9539    root   14u  IPv4    47438      0t0  TCP *:52189 (LISTEN)
1
2
3
4
5
6
7
8
9
3.4、显示UDP链接
[root@centos fd]# lsof -i udp
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
tp_core 9539 root    4u  IPv4  47431      0t0  UDP localhost:59506->localhost:42125 
tp_core 9539 root    5u  IPv4  47432      0t0  UDP localhost:42125->localhost:59506
1
2
3
4
3.5、使用<-i:port>显示与指定端口相关的网络信息
[root@centos fd]# lsof -i :80
COMMAND   PID   USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
nginx   57010 nobody   10u  IPv4 10285494      0t0  TCP *:http (LISTEN)
nginx   78569   root   10u  IPv4 10285494      0t0  TCP *:http (LISTEN)
1
2
3
4
3.6、使用<@host>显示指定到指定主机的连接
[root@centos fd]# lsof -i @localhost
COMMAND   PID   USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
master   9346   root   13u  IPv4    47282      0t0  TCP localhost:smtp (LISTEN)
master   9346   root   14u  IPv6    47283      0t0  TCP localhost:smtp (LISTEN)
tp_core  9539   root    4u  IPv4    47431      0t0  UDP localhost:59506->localhost:42125 
tp_core  9539   root    5u  IPv4    47432      0t0  UDP localhost:42125->localhost:59506 
1
2
3
4
5
6
3.7、使用<@host:port>显示基于主机与端口的连接
[root@centos fd]# lsof -i @192.168.1.222:22
COMMAND   PID USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
sshd    98855 root    3u  IPv4 20214895      0t0  TCP centos.terminal:ssh->192.168.1.45:61534 (ESTABLISHED)
1
2
3
3.8、使用<-s:LISTEN> 查找相关状态的链接
[root@centos fd]#  lsof  -i -sTCP:LISTEN
COMMAND    PID   USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
sshd      9251   root    3u  IPv4    45664      0t0  TCP *:ssh (LISTEN)
sshd      9251   root    4u  IPv6    45666      0t0  TCP *:ssh (LISTEN)
tp_web    9274   root    5u  IPv4    48424      0t0  TCP *:7190 (LISTEN)
master    9346   root   13u  IPv4    47282      0t0  TCP localhost:smtp (LISTEN)

[root@centos fd]#  lsof  -i -sTCP:ESTABLISHED
COMMAND      PID    USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
tp_core     9539    root    4u  IPv4    47431      0t0  UDP localhost:59506->localhost:42125 
tp_core     9539    root    5u  IPv4    47432      0t0  UDP localhost:42125->localhost:59506 
python3.7  87588    root    3u  IPv4 21954669      0t0  TCP centos.terminal:38168->centos.terminal:mysql (ESTABLISHED)
python3.7  87588    root   10u  IPv4 21952856      0t0  TCP centos.terminal:37060->centos.terminal:mysql (ESTABLISHED)
python3.7  87589    root    3u  IPv4 21952923      0t0  TCP centos.terminal:38074->centos.terminal:mysql (ESTABLISHED)
python3.7  87589    root    4u  IPv4 21953768      0t0  TCP centos.terminal:35806->centos.terminal:mysql (ESTABLISHED)
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
3.9、使用<-u <user>>输出指定用户打开的文件（^表示排除）
[root@centos fd]#  lsof  -u root | more
COMMAND      PID USER   FD      TYPE             DEVICE  SIZE/OFF       NODE NAME
systemd        1 root  cwd       DIR              253,0       259         64 /
systemd        1 root  rtd       DIR              253,0       259         64 /
systemd        1 root  txt       REG              253,0   1620416   50477521 /usr/lib/systemd/systemd
systemd        1 root  mem       REG              253,0     20112     468768 /usr/lib64/libuuid.so.1.3.0

[root@centos fd]# lsof  -u ^root | more
COMMAND      PID    TID    USER   FD      TYPE             DEVICE  SIZE/OFF      NODE NAME
dbus-daem   8630           dbus  cwd       DIR              253,0       259        64 /
dbus-daem   8630           dbus  rtd       DIR              253,0       259        64 /
dbus-daem   8630           dbus  txt       REG              253,0    223320  50537182 /usr/bin/dbus-daemon
dbus-daem   8630           dbus  mem       REG              253,0     61624    467113 /usr/lib64/libnss_files-2.17.so
dbus-daem   8630           dbus  mem       REG              253,0     68192     48344 /usr/lib64/libbz2.so.1.0.6
1
2
3
4
5
6
7
8
9
10
11
12
13
14
3.10、杀死指定用户所以进程
[root@centos fd]# lsof  -t -u root | more
1
2
3
5

[root@centos fd]# kill  -9  `lsof -t -u root`
1
2
3
4
5
6
7
3.11、使用<-c <cmd>>查看指定的命令正在使用的文件和网络连接
[root@centos fd]# lsof -c ls
COMMAND    PID USER   FD   TYPE DEVICE  SIZE/OFF     NODE NAME
lsof    107565 root  cwd    DIR    0,3         0 21530740 /proc/9274/fd
lsof    107565 root  rtd    DIR  253,0       259       64 /
lsof    107565 root  txt    REG  253,0    154184  3206106 /usr/sbin/lsof
lsof    107565 root  mem    REG  253,0 106075056 51203612 /usr/lib/locale/locale-archive
1
2
3
4
5
6
3.12、使用<-p <pid>>查看指定进程ID已打开的内容
[root@centos fd]# lsof -p 78569
COMMAND   PID USER   FD   TYPE             DEVICE SIZE/OFF      NODE NAME
nginx   78569 root  cwd    DIR              253,0        6  50570990 /root/grafana-6.2.1/bin (deleted)
nginx   78569 root  rtd    DIR              253,0      259        64 /
nginx   78569 root  txt    REG               8,18 14017904 134792224 /data/webapp/openresty/nginx/sbin/nginx
1
2
3
4
5
3.13、实用的命令
lsof `which httpd` //那个进程在使用apache的可执行文件
lsof /etc/passwd //那个进程在占用/etc/passwd
lsof /dev/hda6 //那个进程在占用hda6
lsof /dev/cdrom //那个进程在占用光驱
lsof -c sendmail //查看sendmail进程的文件使用情况
lsof -c courier -u ^zahn //显示出那些文件被以courier打头的进程打开，但是并不属于用户zahn
lsof -p 30297 //显示那些文件被pid为30297的进程打开
lsof -D /tmp 显示所有在/tmp文件夹中打开的instance和文件的进程。但是symbol文件并不在列
  
lsof -u1000 //查看uid是100的用户的进程的文件使用情况
lsof -utony //查看用户tony的进程的文件使用情况
lsof -u^tony //查看不是用户tony的进程的文件使用情况(^是取反的意思)
lsof -i //显示所有打开的端口
lsof -i:80 //显示所有打开80端口的进程
lsof -i -U //显示所有打开的端口和UNIX domain文件
lsof -i UDP@[url]www.akadia.com:123 //显示那些进程打开了到www.akadia.com的UDP的123(ntp)端口的链接
lsof -i tcp@ohaha.ks.edu.tw:ftp -r //不断查看目前ftp连接的情况(-r，lsof会永远不断的执行，直到收到中断信号,+r，lsof会一直执行，直到没有档案被显示,缺省是15s刷新)
lsof -i tcp@ohaha.ks.edu.tw:ftp -n //lsof -n 不将IP转换为hostname，缺省是不加上-n参数
lsof -P -n | wc -l 统计系统打开的文件总数
lsof -a -c sshd -U 查看被打开的 UNIX domain socket 文件

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
二、gdb工具的使用
c 语言小 demo

#include <stdio.h>

struct idtr
{
        unsigned char byte[10];
};

int main(int argc, char* argv[])
{
        struct idtr idtr;
        int i;

        __asm__ __volatile__ ("SIDT %0" : "=m"(idtr) );
        for (i = 0; i < 10; i++)
                printf("byte %02d: 0x%hhx\n", i, idtr.byte[i]);

        return 0;
}

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
编译 注意必须使用-g参数，编译会加入调试信息，否则无法调试执行文件

gcc -g -Wall -o test test.c
1
1、gdb 调试命令（网络整理）


* gdb 全速运行
(gdb)run，也可只输入 r，程序会开始运行，停在第一个断点处。
(gdb)continue，也可只输入 c，程序继续运行，停在下一个断点处。

* gdb 添加搜索代码源文件路径
(gdb)directory [path]，也可输入 dir [path]，将 path 添加到搜索目录中。

* gdb 打印代码
gdb + 可执行程序即可进入 gdb 调试：
输入 l 可以打印出代码，如果想输出指定行号的代码，可以加上数字，例如 l 5。

* gdb 断点
下断点有两种方式：

*（gdb)break（也可只输入b） + 函数名
*（gdb)break + 行号
*（gdb)break + 条件。这个命令必须在变量i被定义之后才会成功运行，为了解决这个问题，首先在变量 i 被定义的后一行设置中断，然后使用run命令运行程序，程序暂停后就可以使用watch i==99设置断点了。例如
  * break 7 if i==99
  * watch i==99
1
2
3
4
5
查看断点

*显示当前gdb的断点信息：
（gdb) info break
*删除指定的某个断点：
（gdb) delete breakpoint 1
*该命令将会删除编号为1的断点，如果不带编号参数，将删除所有的断点
（gdb) delete breakpoint
*禁止使用某个断点
（gdb) disable breakpoint 1   该命令将禁止断点1，同时断点信息的 (Enb）域将变为 n
*允许使用某个断点
（gdb) enable breakpoint 1    该命令将允许断点1，同时断点信息的 (Enb）域将变为 y
*清除源文件中某一代码行上的所有断点
（gdb)clear number    注：number 为源文件的某个代码行的行号
1
2
3
4
5
6
7
8
9
10
11
12
变量检查赋值编辑

whatis：识别数组或变量的类型
ptype：比whatis的功能更强，他可以提供一个结构的定义
set variable = value：将值赋予变量
print variable = value or p variable = value : 除了显示一个变量的值外，还可以用来赋值
1
2
3
4
单步执行编辑

用start命令开始执行程序
(gdb) start
单步执行(n)
(gdb) n
next 不进入的单步执行
step 进入的单步执行如果已经进入了某函数，而想退出该函数返回到它的调用函数中，可使用命令finish
1
2
3
4
5
6
函数调用编辑

 * call name 调用和执行一个函数
（gdb) call gen_and_sork（1234,1,0)
（gdb) call printf（“abcd”）
  =4
* finish 结束执行当前函数，显示其返回值（如果有的话）  

附录：gdb  常用调试命令
-------------------------------------------------
(gdb) l ：（字母l）列出源码
(gdb) b n :在第n行处设置断点
(gdb) b func：在函数func()的入口处设置断点

(gdb) 条件断点：条件可以是任何合法的c 表达式。 例如 b n if val1==val2

          当已经设置了断点，可以用condition 命令对断点号添加条件， 例: condition 2 val1==val2 , 注意，没有if 单词

          当对变量的改变更感兴趣时，可以用watch 命令

(gdb) info break： 查看断点信息  （更多断点类，见下）
(gdb) r：运行程序
(gdb) n：单步执行
(gdb) s：单步调试如果有函数调用，则进入函数；与命令n不同，n是不进入调用的函数的
(gdb) c：继续运行
(gdb) p 变量 ：打印变量的值     也能够修改变量的值（用 = 赋值） // 打印寄存器值。 p $eax

(gdb) x /nfu <addr> 显示内存  // n为个数，f 为格式，u为每单元长度

命令:x /3uh 0x54320 表示,从内存地址0x54320读取内容,h表示以双字节为一个单位,3表示输出三个单位,u表示按十六进制显示。


(gdb) bt：查看函数堆栈
(gdb) finish：退出函数

(gdb) display <var> 每次中断或单步都显示你关心的变量

(gdb)undisplay <编号>
(gdb) shell 命令行：执行shell命令行
(gdb) set args 参数:指定运行时的参数
(gdb) show args：查看设置好的参数
(gdb)info program： 来查看程序的是否在运行，进程号，被暂停的原因。 // 打印寄存器数组， info reg,  简写 i reg； info threads(注意有s)
(gdb)clear 行号n：清除第n行的断点
(gdb)delete 断点号n：删除第n个断点
(gdb)disable 断点号n：暂停第n个断点
(gdb)enable 断点号n：开启第n个断点
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
三、strace调试命令
1、参数
-c 统计每一系统调用的所执行的时间,次数和出错的次数等. 
-d 输出strace关于标准错误的调试信息. 
-f 跟踪由fork调用所产生的子进程. 
-ff 如果提供-o filename,则所有进程的跟踪结果输出到相应的filename.pid中,pid是各进程的进程号. 
-F 尝试跟踪vfork调用.在-f时,vfork不被跟踪. 
-h 输出简要的帮助信息. 
-i 输出系统调用的入口指针. 
-q 禁止输出关于脱离的消息. 
-r 打印出相对时间关于,,每一个系统调用. 
-t 在输出中的每一行前加上时间信息. 
-tt 在输出中的每一行前加上时间信息,微秒级. 
-ttt 微秒级输出,以秒了表示时间. 
-T 显示每一调用所耗的时间. 
-v 输出所有的系统调用.一些调用关于环境变量,状态,输入输出等调用由于使用频繁,默认不输出. 
-V 输出strace的版本信息. 
-x 以十六进制形式输出非标准字符串 
-xx 所有字符串以十六进制形式输出. 
-a column 
设置返回值的输出位置.默认 为40. 
-e expr 
指定一个表达式,用来控制如何跟踪.格式如下: 
[qualifier=][!]value1[,value2]... 
qualifier只能是 trace,abbrev,verbose,raw,signal,read,write其中之一.value是用来限定的符号或数字.默认的 qualifier是 trace.感叹号是否定符号.例如: 
-eopen等价于 -e trace=open,表示只跟踪open调用.而-etrace!=open表示跟踪除了open以外的其他调用.有两个特殊的符号 all 和 none. 
注意有些shell使用!来执行历史记录里的命令,所以要使用\\. 
-e trace=set 
只跟踪指定的系统 调用.例如:-e trace=open,close,rean,write表示只跟踪这四个系统调用.默认的为set=all. 
-e trace=file 
只跟踪有关文件操作的系统调用. 
-e trace=process 
只跟踪有关进程控制的系统调用. 
-e trace=network 
跟踪与网络有关的所有系统调用. 
-e strace=signal 
跟踪所有与系统信号有关的 系统调用 
-e trace=ipc 
跟踪所有与进程通讯有关的系统调用 
-e abbrev=set 
设定 strace输出的系统调用的结果集.-v 等与 abbrev=none.默认为abbrev=all. 
-e raw=set 
将指 定的系统调用的参数以十六进制显示. 
-e signal=set 
指定跟踪的系统信号.默认为all.如 signal=!SIGIO(或者signal=!io),表示不跟踪SIGIO信号. 
-e read=set 
输出从指定文件中读出 的数据.例如: 
-e read=3,5 
-e write=set 
输出写入到指定文件中的数据. 
-o filename 
将strace的输出写入文件filename 
-p pid 
跟踪指定的进程pid. 
-s strsize 
指定输出的字符串的最大长度.默认为32.文件名一直全部输出. 
-u username 
以username 的UID和GID执行被跟踪的命令
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
在Linux系统上，应用代码通过glibc库封装的函数，间接使用系统调用。

Linux内核目前有300多个系统调用，详细的列表可以通过syscalls手册页查看。这些系统调用主要分为几类：

文件和设备访问类 比如open/close/read/write/chmod等
进程管理类 fork/clone/execve/exit/getpid等
信号类 signal/sigaction/kill 等
内存管理 brk/mmap/mlock等
进程间通信IPC shmget/semget * 信号量，共享内存，消息队列等
网络通信 socket/connect/sendto/sendmsg 等

2、strace两种运行模式
2.1、启动时跟踪
启动时跟踪: 跟踪命令的执行过程
命令格式： strace [-o file] [-e [brk | mmap…]]

[root@centos net]# strace ls
execve("/usr/bin/ls", ["ls"], [/* 26 vars */]) = 0
brk(NULL)                               = 0xbf4000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f8c2e0c9000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=57863, ...}) = 0
mmap(NULL, 57863, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f8c2e0ba000
close(3)                                = 0
1
2
3
4
5
6
7
8
9
2.2 运行时跟踪
跟踪已经在运行的进程
命令格式： strace [-o file] [-e [brk | mmap…]] -p <pid>

[root@centos net]# strace -p 14723
strace: Process 14723 attached
futex(0x7eff2cc1b000, FUTEX_WAIT, 0, NULL) = 0
futex(0x7eff180011d0, FUTEX_WAKE_PRIVATE, 1) = 1
ioctl(3, FIONBIO, [0])                  = 0
sendto(3, "1\0\0\0\3update reptileUrl set getst"..., 53, 0, NULL, 0) = 53
ioctl(3, FIONBIO, [0])                  = 0
1
2
3
4
5
6
7
2.3 统计信息(-c)
统计进程系统调用的耗时情况

[root@centos ~]# strace -c -p 14721
strace: Process 14721 attached
^Cstrace: Process 14721 detached
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
100.00    0.324852           1    241233           wait4
------ ----------- ----------- --------- --------- ----------------
100.00    0.324852                241233           total
1
2
3
4
5
6
7
8
2.4 统计信息指定系统调用
统计进程在一周期中指定系统调用的耗时情况

[root@centos ~]# strace -T -e futex -p 14723
strace: Process 14723 attached
futex(0x7eff2cc1b000, FUTEX_WAIT, 0, NULL) = 0 <4.776972>
futex(0x7eff180011d0, FUTEX_WAKE_PRIVATE, 1) = 1 <0.000017>
futex(0x7eff2cc1b000, FUTEX_WAIT, 0, NULL) = 0 <5.456966>
futex(0x7eff180011d0, FUTEX_WAKE_PRIVATE, 1) = 1 <0.000019>
1
2
3
4
5
6
操作花费时间相关的选项有两个，分别是「-r」和「-T」
「-r」表示相对时间
「-T」表示绝对时间

四、pstack, gstack 显示每个进程的栈跟踪
命令可显示每个进程的栈跟踪。pstack 命令必须由相应进程的属主或 root 运行。可以使用 pstack 来确定进程挂起的位置。此命令允许使用的唯一选项是要检查的进程的 PID。

[root@centos ~]# pstack  102888
#0  0x00007f2ee133612c in waitpid () from /lib64/libpthread.so.0
#1  0x00000000005b8825 in os_waitpid_impl (module=<optimized out>, options=1, pid=102892) at ./Modules/posixmodule.c:7061
#2  os_waitpid (module=<optimized out>, args=<optimized out>, nargs=<optimized out>) at ./Modules/clinic/posixmodule.c.h:3049
#3  0x00000000004653b6 in _PyMethodDef_RawFastCallKeywords (kwnames=0x0, nargs=139839329485752, args=0x7ffd7b3ba908, self=<optimized out>, method=0x8a3ce0 <posix_methods+2400>) at Objects/call.c:651
#4  _PyCFunction_FastCallKeywords (func=func@entry=0x7f2ee18f8dc8, args=args@entry=0x7f2ed46ad9e8, nargs=nargs@entry=2, kwnames=kwnames@entry=0x0) at Objects/call.c:730
#5  0x00000000004ff27d in call_function (kwnames=0x0, oparg=2, pp_stack=<synthetic pointer>) at Python/ceval.c:4568
#6  _PyEval_EvalFrameDefault (f=f@entry=0x7f2ed46ad848, throwflag=throwflag@entry=0) at Python/ceval.c:3093
#7  0x0000000000504738 in PyEval_EvalFrameEx (throwflag=0, f=0x7f2ed46ad848) at Python/ceval.c:547
#8  _PyEval_EvalCodeWithName (_co=0x7f2ed46c8780, globals=<optimized out>, locals=locals@entry=0x0, args=<optimized out>, argcount=<optimized out>, kwnames=0x0, kwargs=0x7f2ed4471bf0, kwcount=<optimized out>, kwstep=kwstep@entry=1, defs=defs@entry=0x7f2ed4461d80, defcount=1, kwdefs=kwdefs@entry=0x0, closure=closure@entry=0x0, name=<optimized out>, qualname=qualname@entry=0x7f2ed44760b0) at Python/ceval.c:3930
#9  0x000000000046512a in _PyFunction_FastCallKeywords (func=<optimized out>, stack=<optimized out>, nargs=<optimized out>, kwnames=<optimized out>) at Objects/call.c:433
#10 0x00000000004fa867 in call_function (kwnames=0x0, oparg=<optimized out>, pp_stack=<synthetic pointer>) at Python/ceval.c:4616
#11 _PyEval_EvalFrameDefault (f=<optimized out>, throwflag=<optimized out>) at Python/ceval.c:3110
#12 0x0000000000464f3a in function_code_fastcall (co=<optimized out>, args=<optimized out>, nargs=1, globals=<optimized out>) at Objects/call.c:283
#13 0x00000000004fa867 in call_function (kwnames=0x0, oparg=<optimized out>, pp_stack=<synthetic pointer>) at Python/ceval.c:4616
#14 _PyEval_EvalFrameDefault (f=f@entry=0x7f2ee19339f8, throwflag=<optimized out>) at Python/ceval.c:3110
#15 0x0000000000506046 in PyEval_EvalFrameEx (throwflag=0, f=0x7f2ee19339f8) at Python/ceval.c:547
#16 _PyEval_EvalCodeWithName (qualname=0x0, name=<optimized out>, closure=0x0, kwdefs=0x0, defcount=0, defs=0x0, kwstep=2, kwcount=0, kwargs=0x0, kwnames=0x0, argcount=0, args=0x0, locals=locals@entry=0x10ca2c0, globals=globals@entry=0x7f2ee19339f8, _co=_co@entry=0x7f2ee18c05d0) at Python/ceval.c:3930
#17 PyEval_EvalCodeEx (closure=0x0, kwdefs=0x0, defcount=0, defs=0x0, kwcount=0, kws=0x0, argcount=0, args=0x0, locals=locals@entry=0x10ca2c0, globals=globals@entry=0x7f2ee19339f8, _co=_co@entry=0x7f2ee18c05d0) at Python/ceval.c:3959
#18 PyEval_EvalCode (co=co@entry=0x7f2ee18c05d0, globals=globals@entry=0x7f2ee1887240, locals=locals@entry=0x7f2ee1887240) at Python/ceval.c:
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
五、pstree以树结构显示进程
选项

-a：显示每个程序的完整指令，包含路径，参数或是常驻服务的标示；
-c：不使用精简标示法；
-G：使用VT100终端机的列绘图字符；
-h：列出树状图时，特别标明现在执行的程序；
-H<程序识别码>：此参数的效果和指定"-h"参数类似，但特别标明指定的程序；
-l：采用长列格式显示树状图；
-n：用程序识别码排序。预设是以程序名称来排序；
-p：显示程序识别码；
-u：显示用户名称；
-U：使用UTF-8列绘图字符；
-V：显示版本信息。
1
2
3
4
5
6
7
8
9
10
11
pstree -p root | grep ad
[root@centos ~]# pstree -p root | grep ad
           |-adb(34924)-+-{adb}(34925)
           |            |-{adb}(34927)
           |            `-{adb}(34928)
           |-lvmetad(4424)
1
2
3
4
5
6


点赞
收藏
分享

————————————————
版权声明：本文为CSDN博主「mimisn」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/mimisn/article/details/93908243
