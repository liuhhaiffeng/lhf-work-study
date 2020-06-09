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


## 刘海峰总结

:Gtags -Ei  exec_simple_query     # -Ei  忽略大小写进行搜索   Gtags pattern  默认其实是 Gtags -c  pattern, 类似于CTRL+], 不足: 使用 -Ei 后, 无法tab自动补全, 不过这不重要
:Gtags -Ei  ^exec_simple.*ry      # 忽略大小写, 并且使用正则进行模糊搜索
:Gtags -Eir ^exec_simple.*ry      # 忽略大小写, 并且使用正则进行"匹配引用"的查找, 嗯, 尽管支持, 查找引用似乎不需要这样
:Gtags -f                         # 查找当前文件中所有tag 符号(即: 所有函数)
> 注: 也可以 :Gtags -f  %         # vim中  % 代表当前文件完整路径
:Gtags -P connection.c            # 查找文件路径 (包括文件夹 和 文件名), 支持tab自动补全
> 注: Gtags -P  ^connection.c$    # 支持正则查找
:Gtags -g  pattern                # 相当于 grep -r

:copen              # 打开quicklist 窗口, 默认快捷键 F2
:cclose             # 关闭qucklist 窗口, 默认快捷键 F4

:cl                 # 最大化查看 quicklist中的内容
:cn
:cp
:cc num             # 跳转到qucklist中指定的条目对应的内容

:!global -u         # 更新 GTAGS

