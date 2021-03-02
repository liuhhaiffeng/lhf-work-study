# [Linux如何查看与测试磁盘IO性能](https://www.cnblogs.com/mauricewei/p/10502539.html)

## 1. 查看磁盘 IO 性能 

### 1.1 top 命令

top 命令通过查看 CPU 的 wa% 值来判断当前磁盘 IO 性能，如果这个数值过大，很可能是磁盘 IO 太高了，当然也可能是其他原因，例如网络 IO 过高等。

![img](https://img2018.cnblogs.com/blog/1276481/201903/1276481-20190311101109001-1356363786.png)

top命令的其他参数代表的含义详见[top命令详解](https://www.cnblogs.com/mauricewei/p/10496633.html)[
](https://www.cnblogs.com/mauricewei/p/10496633.html)

### 1.2 sar 命令

sar 命令是分析系统瓶颈的神器，可以用来查看 CPU 、内存、磁盘、网络等性能。

sar 命令查看当前磁盘性能的命令为：

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@server-68.2.stage.polex.io var ]$ sar -d -p 1 2
Linux 3.10.0-693.5.2.el7.x86_64 (server-68)     03/11/2019     _x86_64_    (64 CPU)

02:28:54 PM       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
02:28:55 PM       sda      1.00      0.00      3.00      3.00      0.01      9.00      9.00      0.90
02:28:55 PM       sdb      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
02:28:55 PM polex_pv-rootvol      1.00      0.00      3.00      3.00      0.01      9.00      9.00      0.90
02:28:55 PM polex_pv-varvol      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
02:28:55 PM polex_pv-homevol      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00

02:28:55 PM       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
02:28:56 PM       sda      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
02:28:56 PM       sdb      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
02:28:56 PM polex_pv-rootvol      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
02:28:56 PM polex_pv-varvol      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
02:28:56 PM polex_pv-homevol      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00

Average:          DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
Average:          sda      0.50      0.00      1.50      3.00      0.00      9.00      9.00      0.45
Average:          sdb      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:    polex_pv-rootvol      0.50      0.00      1.50      3.00      0.00      9.00      9.00      0.45
Average:    polex_pv-varvol      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:    polex_pv-homevol      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

其中， “-d”参数代表查看磁盘性能，“-p”参数代表将 dev 设备按照 sda，sdb……名称显示，“1”代表每隔1s采取一次数值，“2”代表总共采取2次数值。

- await：平均每次设备 I/O 操作的等待时间（以毫秒为单位）。 
- svctm：平均每次设备 I/O 操作的服务时间（以毫秒为单位）。
- %util：一秒中有百分之几的时间用于 I/O 操作。 

对于磁盘 IO 性能，一般有如下评判标准：

正常情况下 svctm 应该是小于 await 值的，而 svctm 的大小和磁盘性能有关，CPU 、内存的负荷也会对 svctm 值造成影响，过多的请求也会间接的导致 svctm 值的增加。

await 值的大小一般取决与 svctm 的值和 I/O 队列长度以 及I/O 请求模式，如果 svctm 的值与 await 很接近，表示几乎没有 I/O 等待，磁盘性能很好，如果 await 的值远高于 svctm 的值，则表示 I/O 队列等待太长，系统上运行的应用程序将变慢，此时可以通过更换更快的硬盘来解决问题。

%util 项的值也是衡量磁盘 I/O 的一个重要指标，如果 %util 接近 100% ，表示磁盘产生的 I/O 请求太多，I/O 系统已经满负荷的在工作，该磁盘可能存在瓶颈。长期下去，势必影响系统的性能，可以通过优化程序或者通过更换更高、更快的磁盘来解决此问题。

默认情况下，sar从最近的0点0分开始显示数据；如果想继续查看一天前的报告；可以查看保存在/var/log/sa/下的sar日志:

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@server-68.2.stage.polex.io var ]$ sar -d -p -f  /var/log/sa/sa11  | more
Linux 3.10.0-693.5.2.el7.x86_64 (server-68)     03/11/2019     _x86_64_    (64 CPU)

09:50:01 AM       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
10:00:01 AM       sda      0.51      0.00      9.06     17.82      0.02     37.65     14.65      0.74
10:00:01 AM       sdb      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
10:00:01 AM polex_pv-rootvol      0.22      0.00      2.50     11.56      0.01     37.44     14.10      0.31
10:00:01 AM polex_pv-varvol      0.30      0.00      6.55     21.97      0.01     38.55     14.73      0.44
10:00:01 AM polex_pv-homevol      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
10:10:01 AM       sda      0.79      3.45     13.18     21.06      0.04     51.81     11.03      0.87
10:10:01 AM       sdb      0.04      3.45      0.00     86.33      0.00      0.25      0.25      0.00
10:10:01 AM polex_pv-rootvol      0.26      0.00      3.08     11.85      0.01     50.21     17.88      0.46
10:10:01 AM polex_pv-varvol      0.54      3.45     10.10     24.95      0.03     52.58      7.49      0.41
10:10:01 AM polex_pv-homevol      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
10:20:01 AM       sda      0.65      0.00     10.43     16.11      0.03     38.67     10.99      0.71
10:20:01 AM       sdb      0.04      3.46      0.00     86.33      0.00      0.08      0.08      0.00
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

### 1.3 iostat 命令

iostat主要用于监控系统设备的 IO 负载情况，iostat 首次运行时显示自系统启动开始的各项统计信息，之后运行 iostat 将显示自上次运行该命令以后的统计信息。用户可以通过指定统计的次数和时间来获得所需的统计信息。

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@server-68.2.stage.polex.io var ]$ iostat -dxk 1 2
Linux 3.10.0-693.5.2.el7.x86_64 (server-68)     03/11/2019     _x86_64_    (64 CPU)

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
sda               0.00     0.06    0.32    2.08     1.44    72.78    61.81     0.14   59.32    0.51   68.37   5.68   1.36
sdb               0.00     0.00    0.03    0.00     1.15     0.00    86.32     0.00    0.17    0.17    0.00   0.16   0.00
dm-0              0.00     0.00    0.00    0.24     0.02     1.56    13.22     0.01   44.55    6.36   44.71  13.25   0.32
dm-1              0.00     0.00    0.32    1.90     1.32    71.22    65.30     0.14   62.43    0.49   72.79   4.75   1.06
dm-2              0.00     0.00    0.00    0.00     0.00     0.00    26.79     0.00   28.06    4.68   38.98   5.18   0.00

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
sda               0.00     0.00    0.00    3.00     0.00    16.00    10.67     0.26   86.33    0.00   86.33  42.33  12.70
sdb               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00    0.00    0.00   0.00   0.00
dm-0              0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00    0.00    0.00   0.00   0.00
dm-1              0.00     0.00    0.00    3.00     0.00    16.00    10.67     0.26   86.33    0.00   86.33  42.33  12.70
dm-2              0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00    0.00    0.00   0.00   0.00
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

该命令的结果与上面 sar -d -p 1 2 命令类似，实际使用中主要还是看 await svctm %util 参数。

### 1.4 vmstat 命令

 vmstat 命令使用方法很简单：

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@server-68.2.stage.polex.io var ]$ vmstat  2
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 3  0      0 93221488   4176 69117136    0    0     0     1    0    0  4  1 94  0  0
 2  0      0 93226048   4176 69117128    0    0     0     0 33326 36671 18  2 80  0  0
 1  0      0 93218776   4176 69117104    0    0     0     9 26225 21588 18  2 80  0  0
 1  0      0 93226072   4176 69117072    0    0     0     0 13271 25857  5  0 94  0  0
 0  0      0 93223984   4176 69117040    0    0     0     5 34637 24444 20  2 78  0  0
11  0      0 93219248   4176 69117184    0    0     0     0 30736 20671  8  2 90  0  0
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

输出结果中，bi bo 可以表示磁盘当前性能：

- bi 块设备每秒接收的块数量，这里的块设备是指系统上所有的磁盘和其他块设备，默认块大小是 1024 byte 。
- bo 块设备每秒发送的块数量，例如我们读取文件，bo 就要大于0。bi 和 bo 一般都要接近 0，不然就是 IO 过于频繁，需要调整。

## 2. 测试磁盘 IO 性能

### 2.1 hdparm 命令

hdparm 命令提供了一个命令行的接口用于读取和设置IDE或SCSI硬盘参数，注意该命令**只能测试磁盘的读取**速率。

例如，测试 sda 磁盘的读取速率：

```
[root@server-68.2.stage.polex.io var ]$ hdparm -Tt /dev/polex_pv/varvol

/dev/polex_pv/varvol:
 Timing cached reads:   15588 MB in  2.00 seconds = 7803.05 MB/sec
 Timing buffered disk reads: 1128 MB in  3.01 seconds = 374.90 MB/sec
```

从测试结果看出，带有缓存的读取速率为：7803.05MB/s ，磁盘的实际读取速率为：374.90 MB/s 。

### 2.2 dd 命令

Linux dd 命令用于读取、转换并输出数据。dd 可从标准输入或文件中读取数据，根据指定的格式来转换数据，再输出到文件、设备或标准输出。

我们可以利用 dd 命令的复制功能，测试某个磁盘的 IO 性能，须要注意的是 dd 命令只能大致测出磁盘的 IO 性能，**不是非常准确**。

测试写性能命令：

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
[root@server-68.2.stage.polex.io var ]$ time dd if=/dev/zero of=test.file bs=1G count=2 oflag=direct
2+0 records in
2+0 records out
2147483648 bytes (2.1 GB) copied, 13.5487 s, 159 MB/s

real    0m13.556s
user    0m0.000s
sys    0m0.888s 
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

可以看到，该分区磁盘写入速率为 159M/s，其中：

- /dev/zero 伪设备，会产生空字符流，对它不会产生 IO 。
- if 参数用来指定 dd 命令读取的文件。
- of 参数用来指定 dd 命令写入的文件。
- bs 参数代表每次写入的块的大小。
- count 参数用来指定写入的块的个数。
- offlag=direc 参数测试 IO 时必须指定，代表直接写如磁盘，不使用 cache 。

测试读性能命令：

```
[root@server-68.2.stage.polex.io var ]$ dd if=test.file of=/dev/null  iflag=direct
4194304+0 records in
4194304+0 records out
2147483648 bytes (2.1 GB) copied, 4.87976 s, 440 MB/s
```

可以看到，该分区的读取速率为 440MB/s

### 2.3 fio 命令

fio 命令是专门测试 iops 的命令，比 dd 命令准确，fio 命令的参数很多，这里举几个例子供大家参考：

顺序读：

```
fio -filename=/var/test.file -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=16k -size=2G -numjobs=10 -runtime=60 -group_reporting -name=test_r
```

随机写：

```
fio -filename=/var/test.file -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=psync -bs=16k -size=2G -numjobs=10 -runtime=60 -group_reporting -name=test_randw
```

顺序写：

```
fio -filename=/var/test.file -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=16k -size=2G -numjobs=10 -runtime=60 -group_reporting -name=test_w
```

混合随机读写：

```
fio -filename=/var/test.file -direct=1 -iodepth 1 -thread -rw=randrw -rwmixread=70 -ioengine=psync -bs=16k -size=2G -numjobs=10 -runtime=60 -group_reporting -name=test_r_w -ioscheduler=noop
```

 

参考链接：

https://elf8848.iteye.com/blog/2168876

https://linuxtools-rst.readthedocs.io/zh_CN/latest/tool/sar.html

http://blog.sina.com.cn/s/blog_62b832910102w3zt.html

https://www.cnblogs.com/ggjucheng/archive/2013/01/13/2858810.html

https://linux.cn/article-6104-1.html

http://www.runoob.com/linux/linux-comm-hdparm.html





## 刘海峰备注

其中, sar -d -p 1 2 命令感觉挺好用的.