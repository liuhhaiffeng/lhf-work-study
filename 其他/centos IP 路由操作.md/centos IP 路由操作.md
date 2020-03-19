**linux - ip route 操作主机路由**

![](media/eab097a8cf8a601432ff8e0dbdbd2798.jpg)

linux运维菜

发布时间：18-12-0510:55优质原创作者

<https://baijiahao.baidu.com/s?id=1618978745521215381&wfr=spider&for=pc>

**前言**

![](media/6cb7bb19b3e35850fa266085358d916c.jpg)

在Linux中，我们经常会涉及到修改主机的路由列表，以前都是使用route这个命令，但是在CentOS7中默认已经不安装net-tools这个包，所以默认是没有route这个命令的，可以使用ip
route 代替。

**ip route**

![](media/cec3aa15143d91e10eea4991c20abb47.jpg)

ip这个命令是在iproute2包里面，在CentOS7中默认就安装了。

**列出路由**

ip route list

ip route show

ip route

**查看指定网段的路由**

ip route list 192.168.2.0/24

**添加路由**

ip route add 192.168.2.0/24 via 192.168.1.1

**追加路由**

ip route append 192.168.2.0/24 via 192.168.1.12
\#追加一个指定网络的路由，为了平滑切换网关使用

**修改路由**

ip route change 192.168.2.0/24 via 192.168.1.11

ip route replace 192.168.2.0/24 via 192.168.1.111

**删除路由**

ip route del 192.168.2.0/24 via 192.168.1.1

**清空指定网络的路由**

ip route flush 192.168.2.0/24
\#这个是清理所有192.168.2.0/24相关的所有路由，有时候设置错网关存在多条记录，就需要一次性清空相关路由再进行添加

**添加默认路由**

ip route add default via 192.168.1.1

**指定路由metirc**

ip route add 192.168.2.0/24 via 192.168.1.15 metric 10

**route命令**

![](media/17f52902042467cc7b48b5ce1739c957.jpg)

为了兼容CentOS7也提供了net-tools包，只是没有默认安装而已。可以直接使用yum进行安装。

yum -y install net-tools

centos 路由操作
---------------

**查看路由**

route -n

**添加路由**

route add -net 192.168.2.0/24 gw 192.168.1.1

route add -host 192.168.2.100/32 gw 192.168.1.1

**删除路由**

route del -net 192.168.2.0/24 gw 192.168.1.1

route del -host 192.168.2.100/32 gw 192.168.1.1

**添加默认路由**

route add default gw 192.168.1.1
