vim Gtags学习
=============

https://blog.csdn.net/iteye_1222/article/details/82324845

Vim中Gtags操作的标注格式是：

 

:Gtags [option] pattern

function：  :Gtags func\<TAB\>

支持标准POSIX正则式： :Gtags \^[sg]et\_

function reference： :Gtags -r func

符号(非全局定义)： :Gtags -s func

普通字符串：:Gtags -g xxx

文件中定义的数据：:Gtags -f filename/%(当前文件)

文件浏览： :Gtags -P regular

跳转到定义位置：:Gtags Cursor

Quickfix list操作：

-   :cn'  下一个

-   :cp' 上一个

-   :ccN' 去第N个

-   :cl' 显示全部
