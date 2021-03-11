# Linux内核调优

## 为什么需要内核调优

大部分的linux发行版是为了完全兼容市场中大部分计算机而设计的。这是一个相当混杂的硬件集合（硬盘，显卡，网卡，等等）。所以Red Hat， Suse，Mandriva和其他的一些发行版厂商选择了一些保守的设置来确保安装成功。 简单地说：你的发行版运行的很好，但是它可以运行地更好！ 比如，可能有一个具体一些特殊特性的高级硬盘，而这些特性在标准配置的情况下可能就没被启用。 

## 调优的方法有哪些

### /proc下直接修改

Linux系统上的/proc目录是一种文件系统，即proc文件系统。与其它常见的文件系统不同的是，/proc是一种伪文件系统（也即虚拟文件系统），存储的是当前内核运行状态的一系列特殊文件，用户可以通过这些文件查看有关系统硬件及当前正在运行进程的信息，甚至可以通过更改其中某些文件来改变内核的运行状态。 

基于/proc文件系统如上所述的特殊性，其内的文件也常被称作虚拟文件，并具有一些独特的特点。例如，其中有些文件虽然使用查看命令查看时会返回大量信息，但文件本身的大小却会显示为0字节。此外，这些特殊文件中大多数文件的时间及日期属性通常为当前系统时间和日期，这跟它们随时会被刷新（存储于RAM中）有关。 

为了查看及使用上的方便，这些文件通常会按照相关性进行分类存储于不同的目录甚至子目录中，如/proc/scsi目录中存储的就是当前系统上所有SCSI设备的相关信息，/proc/N中存储的则是系统当前正在运行的进程的相关信息，其中N为正在运行的进程（可以想象得到，在某进程结束后其相关目录则会消失）。 

大多数虚拟文件可以使用文件查看命令如cat、more或者less进行查看，有些文件信息表述的内容可以一目了然，但也有文件的信息却不怎么具有可读性。不过，这些可读性较差的文件在使用一些命令如apm、free、lspci或top查看时却可以有着不错的表现。

### sysctl命令修改

**个人一般sysctl -p 或sysctl -a比较多使用** 

sysctl配置与显示在/proc/sys目录中的内核参数．可以用sysctl来设置或重新设置联网功能，如IP转发、IP碎片去除以及源路由检查等。用户只需要编辑/etc/sysctl.conf文件，即可手工或自动执行由sysctl控制的功能。

  命令格式：

  sysctl [-n] [-e] -w variable=value

  sysctl [-n] [-e] -p <filename> (default /etc/sysctl.conf)

  sysctl [-n] [-e] -a

  常用参数的意义：

  -w  临时改变某个指定参数的值，如

​     sysctl -w net.ipv4.ip_forward=1

  -a  显示所有的系统参数

  -p  从指定的文件加载系统参数，如不指定即从/etc/sysctl.conf中加载

  如果仅仅是想临时改变某个系统参数的值，可以用两种方法来实现,例如想启用IP路由转发功能：

  1) #echo 1 > /proc/sys/net/ipv4/ip_forward

  2) #sysctl -w net.ipv4.ip_forward=1

  以上两种方法都可能立即开启路由功能，但如果系统重启，或执行了

  \# service network restart

 命令，所设置的值即会丢失，如果想永久保留配置，可以修改/etc/sysctl.conf文件

 将 net.ipv4.ip_forward=0改为net.ipv4.ip_forward=1

### /etc/sysctl.conf下配置

/proc/sys目录下存放着大多数内核参数，并且可以在系统运行时进行更改，不过重新启动机器就会失效。/etc/sysctl.conf是一个允许改变正在运行中的Linux系统的接口，它包含一些TCP/IP堆栈和虚拟内存系统的高级选项，修改内核参数永久生效。也就是说/proc/sys下内核文件与配置文件sysctl.conf中变量存在着对应关系。

直接通过修改sysctl.conf文件来修改Linux内核参数，下面是我的配置：

```sh
fs.file-max = 999999
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.ip_local_port_range =1024    61000
net.ipv4.tcp_rmem =4096 32768 262142
net.ipv4.tcp_wmem =4096 32768 262142
net.core.netdev_max_backlog = 8096
net.core.rmem_default = 262144
net.core.wmem_default = 262144
net.core.rmem_max = 2097152
net.core.rmem_max = 2097152
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
```

解释一下sysctl.conf文件中参数的意义：

- file-max：这个参数表示进程可以同时打开的最大句柄数，这个参数直接限制最大并发连接数。
- tcp_tw_reuse：这个参数设置为1,表示允许将TIME-WAIT状态的socket重新用于新的TCP链接。这个对服务器来说很有意义，因为服务器上总会有大量TIME-WAIT状态的连接。
- tcp_keepalive_time：这个参数表示当keepalive启用时，TCP发送keepalive消息的频度。默认是7200 seconds，意思是如果某个TCP连接在idle 2小时后，内核才发起probe。若将其设置得小一点，可以更快地清理无效的连接。
- tcp_fin_timeout：这个参数表示当服务器主动关闭连接时，socket保持在FIN-WAIT-2状态的最大时间。
- tcp_max_tw_buckets：这个参数表示操作系统允许TIME_WAIT套接字数量的最大值，如果超过这个数字，TIME_WAIT套接字将立刻被清除并打印警告信息。默认是i180000,过多TIME_WAIT套接字会使Web服务器变慢。
- tcp_max_syn_backlog：这个参数表示TCP三次握手建立阶段接受WYN请求队列的最大长度，默认1024,将其设置大一些可以使出现Nginx繁忙来不及accept新连接的情况时，Linux不至于丢失客户端发起的连接请求。
- ip_local_port_range：这个参数定义了在UDP和TCP连接中本地端口的取值范围。
- net.ipv4.tcp_rmem：这个参数定义了TCP接受缓存（用于TCP接收滑动窗口）的最小值，默认值，最大值。
- net.ipv4.tcp_wmem：这个参数定义了TCP发送缓存（用于TCP发送滑动窗口）的最小值，默认值，最大值。
- netdev_max_backlog：当网卡接收数据包的速度大于内核处理的速度时，会有一个队列保存这些数据包。这个参数表示该队列的最大值。
- rmem_default：这个参数表示内核套接字接收缓存区默认的大小。
- wmem_default：这个参数表示内核套接字发送缓存区默认的大小。
- rmem_max：这个参数表示内核套接字接收缓存区默认的最大大小。
- wmem_max：这个参数表示内核套接字发送缓存区默认的最大大小。