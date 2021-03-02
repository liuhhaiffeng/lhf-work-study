# [vim中多标签和多窗口的使用](https://www.cnblogs.com/loveyakamoz/p/3472239.html)

用vim进行编辑的时候常常因为要编辑多个文件或者是编辑一个文件要参考其他文件而烦恼，这里介绍两种方法：

1.多标签

直接在编辑的时候输入：

vim -p 要编辑的文件名

如vim -p * 就是编辑当前目录的所有文件

多个标签间进行切换时向右切换gt，向左切换用gT

在编辑的时候想增加一个标签就可以:tabnew filename

:tabc    关闭当前的tab
:tabo    关闭所有其他的tab
:tabs    查看所有打开的tab
:tabp   前一个
:tabn   后一个

 

要想关闭保存所有文件就可以:wqall

 

2.多窗口

窗口可以是水平和竖直的。水平就是在编辑的时候采用hsplit，竖直采用:vsplit filename

窗口间切换用命令ctrl+w+w即可

关闭命令一样。



from  https://www.cnblogs.com/loveyakamoz/p/3472239.html