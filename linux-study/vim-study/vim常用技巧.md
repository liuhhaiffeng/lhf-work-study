## 查看 vimtutor

vimtutor是个命令, 可以直接运行

## vim下打开文件

:e  可以打开指定文件

ctrl-D 可以列出当前目录下的所有文件和目录

## vim下如何使用help

在vim下输入命令, :h  或  :help

:h  /           查找关于搜索 /  的内容
:h  :e          查找关于 :e 的内容

## 选择区域查找

vim打开一个*.c的文件, 比如我只想在某个函数体内进行查找, 目前我使用的方法个人觉得很不错, 介绍如下:
1) 进入选择模式, 选中函数体
2) :e 1  打开一个临时文件
3) p  粘贴内容

这时就可以在此临时文件中进行查找和替换了

缺点1: 临时文件没有语法高亮, 查看不方便
解决: 使用 :set filetyep=c (简写 :set ft=c)  临时指定文件类型, 语法高亮理解生效

缺点2: 临时文件没保存之前, 无法切换回原先的文件
解决: :sp 或 :vs  split窗口, 这样临时文件和原先的文件就都可以查看, 然后在窗口之间跳转切换即可.

## vim 文件指定临时文件类型, 以实现不同的语法高亮

使用 :set filetyep=c (简写 :set ft=c)  临时指定文件类型, 语法高亮理解生效


ctags指定文件
原创warcraftzhaochen 最后发布于2017-06-13 17:17:23 阅读数 455  收藏
展开
find . -name "*.h" -o -name "*.asm" -o -name "*.c"  | ctags -f .tags --c-kinds=+l -L -
————————————————
版权声明：本文为CSDN博主「warcraftzhaochen」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/warcraftzhaochen/article/details/73188682

## 一次性退出所有 vimdiff

git, 使用vimdiff比较文件时, 有可能会打开很多文件,  2个比较文件的退出是  :qa
而整个vimdiff的退出为  :qall

## vim 高亮插件 taghighlight

安装后, 如果高亮不生效, 可以在vim中执行如下的命令
:UpdateTypesFile

## vim 中cd跳转到当前打开的文件所在的目录

:cd %:h

## vim 查找当前选中的内容

让光标停留在单词的第一个字母上， 然后输入yw拷贝该单词， 然后输入 / (Ctrl + R) 0 （即 /”0），回车， 就查找到了第一个匹配的单词， 并且可以通过 n  或  N 进行上一个或下一个的匹配。

## vim调整窗口大小

:hlpe resize

将主编辑窗口设置为宽度为80
:vertical resize 80