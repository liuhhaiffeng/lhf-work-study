# 如何使用Linux Sleep命令暂停Bash脚本

Linux公社 2019-05-16
Sleep是一个命令行实用程序，允许您将调用进程挂起一段指定的时间。也就是说，sleep命令在给定的时间内暂停下一个命令的执行。
当在bash shell脚本中使用sleep命令时，例如在重试失败的操作或循环时，该命令尤其有用。
在本教程中，我们将向您展示如何使用Linux sleep命令。
如何使用Sleep命令
sleep命令的语法如下:
sleep NUMBER [SUFFIX]...
NUMBER可以是正整数或浮点数。
SUFFIX可以是下列之一:
• s  - 秒（默认）
• m  - 分钟
• h  - 小时
• d  - 天
当没有使用SUFFIX时，默认为秒。
当指定两个或多个参数时，总时间量等于它们的值之和。
下面是几个简单的例子，演示如何使用sleep命令:
暂停7秒钟:
• sleep 7
暂停0.7秒钟:
• sleep 0.7
暂停1分50秒：
• sleep 2m 30s
Bash脚本示例
以下是如何在Bash脚本中使用sleep命令的最基本示例。 运行脚本时，它将以HH：MM：SS格式打印当前时间。 然后sleep命令将暂停脚本5秒钟。 当指定的时间段过去后，脚本的最后一行将再次打印当前时间。
#!/bin/bash

# 开始时间
echo "开始时间" 
date +"%H:%M:%S"

# 暂停8秒
sleep 8

# 结束时间
echo "结束时间" 
date +"%H:%M:%S"
输出看起来像这样(如下图)：
开始时间
06:06:07
结束时间
06:06:15
我们再来看一个更高级的例子。
#!/bin/bash

while :
do
if ping -c 1 www.linuxidc.com &> /dev/null
then
echo "Linux公社www.linuxidc.com正在服务中"
break
fi
sleep 5
done
上面的脚本将每隔5秒检查主机是否在线，当主机上线时，脚本会通知您并停止。
运行脚本，如下图：
linuxidc@linuxidc:~/linuxidc.com$ ./linuxidc.com.sh
Linux公社www.linuxidc.com正在服务中
脚本的工作原理：
• 在第一行中，我们创建了一个无限while循环。
• 然后我们使用ping命令来确定IP地址为ip_address的主机是否可访问。
• 如果主机可访问，则脚本将回显“主机已联机”并终止循环。
• 如果主机无法访问，则sleep命令会暂停脚本5秒钟，然后循环从头开始。
总结
到目前为止，您应该能很好地理解如何使用Linux sleep命令，还不懂，那就不要问我了。
sleep命令是最简单的shell命令之一，只接受一个用于指定sleep间隔的参数。
更多Linux命令相关信息见Linux命令大全 专题页面 https://www.linuxidc.com/topicnews.aspx?tid=16
Linux公社的RSS地址：https://www.linuxidc.com/rssFeed.aspx
本文永久更新链接地址：https://www.linuxidc.com/Linux/2019-05/158677.htm



支持就点下在看并转发朋友圈吧
阅读原文
阅读 1347
 在看2

写下你的留言
精选留言
•  4
塞北的雪

暂停1分50秒： sleep 2m 30s 要严谨啊
 1
作者
测试了多个，写了这个，谢谢
•  
SRJ

原文中的 暂停1分50秒：sleep 2m 30s，，是这样的写法吗？有点看不懂，还是写错了
 
作者
谢谢，写错了

来自 <https://mp.weixin.qq.com/s?__biz=MjM5NDEwNzc0MQ==&mid=2650936279&idx=2&sn=1c71b40f0e1ee488df3de2f8f95c8593&scene=0&key=37b4d3bb1636246f2065fb572d6100c4424d0f97b08b12051af3a448e2e068ccc0d3f1653629391d9d2fc4539fd5746e163f4b8e698df5db424ed4c466c139f1552e748b5308406499e12ea746d07f70&ascene=1&uin=OTU4OTYyMDYw&devicetype=Windows+10&version=62080079&lang=zh_CN&exportkey=ATG72P6bmaeqjfyyW%2BEPRns%3D&pass_ticket=IABm4%2Bzr8qA8gYwDbI27D5N0EFKLYXotjRBs7DPBMrRWzXh86Q%2BESWRFG9YoqbzZ&winzoom=1> 
