# gdb 使用技巧

## 打印所有线程堆栈

下面2种写法均可以实现相同功能:

thread apply all where
thread apply all bt

备注: 如果不用gdb, 还可以在进程内部和外部, 通过pstack和gstack实现相同的目的.

进程内, 即在代码中
char str[128] = {0};
sprintf(str, "pstack %d", getpid());  或 sprintf(str, "gstack %d", getpid());
system (str);

进程外:
sudo pstack pid
sudo gstack pid


## gdb 附加进程调试

sudo gdb -p pid

sudo gdb
file /home/uxdb/uxdbinstall/dbsql/bin/uxdb
attach pid


## gdb 修改源码查找路径

gdb 默认搜索的源码路径为其"make install"时的源码目录

在gdb调试中可以也修改指定的源码路径:
gdb $  dir  xx/xx/xxx

即使用在gdb运行过程中, 使用 dir 可以重定向源码目录

## gdb 查看调试堆栈

info frame   简写  i f

i f  默认查看的是第0帧(0 frame)的堆栈

i f 1   第1 frame
i f 2   第2 frame

## gdb 调试子进程

```sh
(gdb) show follow-
follow-exec-mode  follow-fork-mode  
(gdb) show follow-fork-mode 
Debugger response to a program call of fork or vfork is	"parent".
(gdb) show detach-on-fork 
Whether	gdb will detach	the child of a fork is on.
(gdb) 
```

调试父进程和子进程设置
```sh
(gdb) set follow-fork-mode child
(gdb) set detach-on-fork off
```

每次进入gdb, 都有进行上述设置, 比较麻烦, gdb和vim一样, 也有配置文件, 位于家目录下的.gdbinit, 如果没有此文件, 新建之.
设置如下:

```sh
[uxdb@192 ~]$ vi ~/.gdb
.gdb_history  .gdbinit        
[uxdb@192 ~]$ cat  ~/.gdbinit
#set listsize 20
set follow-fork-mode child
set detach-on-fork off
[uxdb@192 ~]$ 
```

## gdb set args 

```sh
set args -D racdata -o "-c uxdb_rac=on -c master_id=1 -c node_id=1 -p 5432" -l logfile start
start
```

## gdb 运行

start

run

## gdb 运行到指定行

until line

## gdb --tui 模式下(上下翻动命令)

非 tui下, 使用"上下方向键"来上下翻动命令
而 tui下, "上下方向键"用来移动tui窗口代码, tui下面窗口使用"Ctrl+P, Ctrl+N"

## gdb 窗口编辑调试文件

gdb中, 输入 edit 即可.

## gdb 调试的时候被信号终止

输入命令info signals或 info handle 查看信号
用以下命令设置即可，收到SIGUSR1不会终止
handle SIGUSR1 nostop



## 将后台的gdb进程恢复到前台

在gdb调试时, 有时候不小心按下了 ctrl+z, 将调试进程转到了后台, 以前不知道如何解决, 只能使用kill 杀掉后台gdb进程, 重写调试, 但在有些场合, gdb的调试机会非常宝贵, 终止了, 可能问题就不好再复现了.

如果将后台进程恢复到前台呢? 步骤如下:

1. jobs      执行jobs 命令查看当前在后台的job, 找到目标job号, 即job id.
2. fg % "job id"   执行fg % x  命令,  其中x是目标job id.  fg后面一个百分号, 再加jobid, 即可将后台job恢复到前台.