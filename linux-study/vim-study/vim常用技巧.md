
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