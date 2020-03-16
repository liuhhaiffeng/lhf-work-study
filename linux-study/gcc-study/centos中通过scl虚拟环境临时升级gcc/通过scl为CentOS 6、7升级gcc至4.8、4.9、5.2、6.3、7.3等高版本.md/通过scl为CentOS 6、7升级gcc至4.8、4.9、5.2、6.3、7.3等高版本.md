通过scl*为CentOS 6、7升级gcc至4.8、4.9、5.2、6.3、7.3等高版本*

2019年01月7日 上午 \| 作者：VPS侦探

![](media/563456f06696ec4ab148bdd5ac68c9f0.png)

CentOS 7虽然已经出了很多年了，但依然会有很多人选择安装CentOS 6，CentOS
6有些依赖包和软件都比较老旧，如今天的主角gcc编译器，CentOS
6的gcc版本为4.4，CentOS 7为4.8。gcc
4.8最主要的一个特性就是全面支持C++11，如果不清楚什么用的也没关系，简单说一些C++11标准的程序都需要gcc
4.8以上版本的gcc编译器编译，如MySQL 8.0版本(8.0.16以上版本是C++14标准，需gcc
5.3以上版本)。

CentOS 6虽然是gcc 4.4的老旧版本，但是也可以升级gcc来安装gcc
4.8，我们今天就不采用编译安装的方法了，gcc安装起来非常费时，我们采用CentOS的一个第三方库SCL(软件选集)，SCL可以在不覆盖原系统软件包的情况下安装新的软件包与老软件包共存并且可以使用scl命令切换，不过也有个缺点就是只支持64位的。

确定当前gcc版本，执行命令：gcc --version

一般如果需要升级gcc至4.8或更高版本，建议直接采用安装SCL源之后安装devtoolset-6（devtoolset-6目前gcc版本为6.3），因为devtoolset-4及之前的版本都已经结束支持，只能通过其他方法安装

**升级到gcc 6.3：**

yum -y install centos-release-scl

yum -y install devtoolset-6-gcc devtoolset-6-gcc-c++ devtoolset-6-binutils

scl enable devtoolset-6 bash

需要注意的是scl命令启用只是临时的，退出shell或重启就会恢复原系统gcc版本。

如果要长期使用gcc 6.3的话：

echo "source /opt/rh/devtoolset-6/enable" \>\>/etc/profile

这样退出shell重新打开就是新版的gcc了

以下其他版本同理，修改devtoolset版本号即可。

VPS侦探 <https://www.vpser.net>

**升级到gcc 7.3：**

yum -y install centos-release-scl

yum -y install devtoolset-7-gcc devtoolset-7-gcc-c++ devtoolset-7-binutils

scl enable devtoolset-7 bash

需要注意的是scl命令启用只是临时的，退出shell或重启就会恢复原系统gcc版本。

如果要长期使用gcc 7.3的话：

echo "source /opt/rh/devtoolset-7/enable" \>\>/etc/profile

**再说一下已经停止支持的devtoolset4(gcc 5.2)及之前版本的安装方法**

**升级到gcc 4.8：**

wget <http://people.centos.org/tru/devtools-2/devtools-2.repo> -O
/etc/yum.repos.d/devtoolset-2.repo

yum -y install devtoolset-2-gcc devtoolset-2-gcc-c++ devtoolset-2-binutils

scl enable devtoolset-2 bash

**升级到gcc4.9：**

wget
<https://copr.fedoraproject.org/coprs/rhscl/devtoolset-3/repo/epel-6/rhscl-devtoolset-3-epel-6.repo>
-O /etc/yum.repos.d/devtoolset-3.repo

yum -y install devtoolset-3-gcc devtoolset-3-gcc-c++ devtoolset-3-binutils

scl enable devtoolset-3 bash

**升级到gcc 5.2**

wget
<https://copr.fedoraproject.org/coprs/hhorak/devtoolset-4-rebuild-bootstrap/repo/epel-6/hhorak-devtoolset-4-rebuild-bootstrap-epel-6.repo>
-O /etc/yum.repos.d/devtoolset-4.repo

yum install devtoolset-4-gcc devtoolset-4-gcc-c++ devtoolset-4-binutils -y

scl enable devtoolset-4 bash

好了，至此各个主要gcc版本的安装教程，如有问题可以本文回复或者[VPS论坛](https://bbs.vpser.net/)发帖。

\-----------------------------------------------------------------------------------------------------------------

论坛注册邀请码：[3213c3c922jBm1cs](https://bbs.vpser.net/reg.php?invitecode=3213c3c922jBm1cs) 有效期至：2019-1-21
09:31

**\>\>转载请注明出处：**[VPS侦探](https://www.vpser.net/)** 本文链接地址：**<https://www.vpser.net/manage/centos-6-upgrade-gcc.html>

 

*来自 \<*<https://www.vpser.net/manage/centos-6-upgrade-gcc.html>*\>*
