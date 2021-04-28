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

## vim 查看搜索和跳转历史

命令模式下, 键入: q/   即可弹出搜索历史 Quickfix List窗口, 再按下 CTRL-C, 可直接跳到命令窗口进行输入

命令模式下, 键入: q:  即可弹出跳转历史Quckfix List窗口, 再按下 CTRL-C, 可直接跳到命令窗口进行输入

【vim显示历史命令】

q: 进入命令历史编辑。
类似的还有 q/ 可以进入搜索历史编辑。
注意 q 后面如果跟随其它字母，是进入命令记录。

可以像编辑缓冲区一样编辑某个命令，然后回车执行。
也可以用 ctrl-c 退出历史编辑，但此时历史编辑窗口不关闭，可以参照之前的命令再自己输入。
用 :x 关闭历史编辑并放弃编辑结果，也可以在空命令上回车相当于退出。

参考：http://zhidao.baidu.com/link?url=Zsi4pz8qxYATGPGkf9wlMbA7xBVdjyCm1jn5c5pQZGH2gtp6lzRcngR0kmMbV6c3pt3q-LeAxQCMKrgkEjz6Ba

## vim 将使用yy或yaw的内容拷贝到命令窗口

1. yy或yaw复制内容
2. 命令窗口, CTRL-R, 然后在按下0, 就将复制的内容拷贝到命令行中了.

> 注: 使用yy拷贝到命令行的内容后面包含了一个"^M", 这个是"换行符"
>     如果复制整行, 但不包括末尾的"换行符", 可以使用  y$  即: 复制到行末尾, 但不包括"换行符"


##  vim 当前文件名及目录的快捷符号

%               #  %  表示当前文件名
%:h             # %:h 表示当前文件目录

如:     
:!ls -lh  %     # 查看当前文件的详细信息
:!ls  %:h       # 查看当前文件所在目录下的内容

vim help查看方式(:h  或 :help)
:h %
:h %:h



## vim 关闭 :ls 中多个文件中的一个

:bd        # 关闭 :ls 中的当前文件

:bd n     # 关闭 :ls 中序号为n的文件



更多参见 :h  bd



## vim 关闭 sp, vsp的切分窗口, 只保留当前一个



<C-W> o       # Ctrl-W  o  o是only的意思



如果是想保留其中一个分割窗口,把其它的都关上,那么是 <C-W>o。o 是 Only 的意思



## vim Shift+ZZ



ZZ                      Write current file, if modified, and quit (same as
                        ":x").  (Note: If there are several windows for the
                        current file, the file is written if it was modified
                        and the window is closed).



## ## 在文件之间切换

1.文件间切换
Ctrl+6—下一个文件
:bn—下一个文件
:bp—上一个文件
对于用(v)split在多个窗格中打开的文件，这种方法只会在当前窗格中切换不同的文件。
2.在窗格间切换的方法
Ctrl+w+方向键——切换到前／下／上／后一个窗格
Ctrl+w+h/j/k/l ——同上
Ctrl+ww——依次向后切换到下一个窗格中

3.多文档编辑的命令如下

:n     编辑下一个文档。
:2n    编辑下两个文档。
:N     编辑上一个文档。注意，该方法只能用于同时打开多个文档。
:e 文档名    这是在进入vim后，不离开 vim 的情形下打开其他文档。
:e# 或 Ctrl+6   编辑上一个文档,用于两个文档相互交换编辑时使用。?# 代表的是编辑前一次编辑的文档
:files 或 :buffers 或 :ls   可以列出目前 缓冲区 中的所有文档。加号 + 表示 缓冲区已经被修改过了。＃代表上一次编辑的文档，%是目前正在编辑中的文档
:b 文档名或编号   移至该文档。
:f 或 Ctrl+g   显示当前正在编辑的文档名称。
:f 檔名     改变编辑中的文档名。(file)

**多文件切换**

1. 通过vim打开多个文件（可以通过ctags或者cscope）
2. ":ls"查看当前打开的buffer（文件）
3. ":b num"切换文件（其中num为buffer list中的编号）

https://www.cnblogs.com/pengdonglin137/p/3525297.html



## vim 在 :ls 中直接输入命令进行文件的切换

1.  :ls

   会显示出文件列表

2. :bn

      这时, 在:ls的quicklist窗口中直接输入   :bn     , 这里n是你要切换的文件编号, 就可以直接切换了.  

      > 以前不知道可以在 :ls 的窗口中直接输入命令,  :ls  和  :bn 总是要执行两次, 感觉很麻烦, 原来可以简单啊.



## vim状态保存和恢复

[vim状态保存跟恢复](https://www.cnblogs.com/zhangshuli-1989/p/hq_vim_151019165.html)

当我们结束了一天的工作的时候，可能手头的工作仅仅进行了一半，比如我们正在用vim修改一个android 问题，我们定位了问题关键，牵扯到了好几个类，如果这时候我们直接把vim关闭了，那我们下次还要重新打开，很麻烦。其实，这时候我们可以通过如下的两条命令来保存当前的状态，并在需要的时候重新打开。

```
mksession            --进入命令行模式，执行.缺省生成文件名为Session.vim
source sessionfile   --在vim命令行模式下，执行此命令

快捷键:
mks!
so sessionfile
```



## [在Vim中快速从垂直分割切换到水平分割](https://my.oschina.net/u/3797416/blog/3154575)

当您有两个*或多个*水平或垂直打开的窗口并希望将它们*全部*切换到另一个方向时，您可以使用以下内容：

（切换到水平）

```
:windo wincmd K
```

（切换到垂直）

```
:windo wincmd H
```

它有效地单独使用^ W K或^ W H到达每个窗口。



## 更加方便的(水平或垂直)分割

 [在Vim中快速从垂直分割切换到水平分割](https://my.oschina.net/u/3797416/blog/3154575)

在VIM中，请查看以下内容，了解您可能已做的不同选择：

：帮助打开窗口

例如：

Ctrl - W s              水平分割               s: 水平
Ctrl - W o              恢复到一个窗口     o: only one window
Ctrl - W v              垂直分割            v:  垂直  vertical



lhf注:灵活应用上面3个命令, 可以实现像vscode哪些任意分割窗口.



## 关闭打开的某个文件

执行 :bd 即可, 详细查看帮助  :h bd

如果不保存退出某 buf 的话，应该是 :bd! 代表把当前 buffer 强制删除



## vim+Doxygen实现注释自动生成

 https://blog.csdn.net/bodybo/article/details/78685640



## [vim宏录制的操作](https://www.cnblogs.com/zoutingrong/p/12323978.html)

1：在vim编辑器normal模式下输入qa（其中a为vim的寄存器）

2：此时在按i进入插入模式，vim编辑器下方则会出现正在录制字样，此时便可以开始操作。

3：需要录制的操作完成后，在normal模式下按q则会退出录制，则此时一个宏录制的完整操作则完成

4：在normal模式下按@a则会重复宏录制中的操作



## vim中git blame和git show

在vim中如何查看blame历史，以及配合git show查看blame详情。

例如，如果想要查看当前文本的blame历史，如下操作：

```c
eea587cbaea (Haifeng Liu 2021-04-02 08:16:24 +0000 1117) static void NotifyAgainMarkDirtyAndFlushBuffer(PiSendEntry *entry)
eea587cbaea (Haifeng Liu 2021-04-02 08:16:24 +0000 1118) {
eea587cbaea (Haifeng Liu 2021-04-02 08:16:24 +0000 1119)        PIMessage piSendMsg;
eea587cbaea (Haifeng Liu 2021-04-02 08:16:24 +0000 1120)        PIMessage replyMsg;
eea587cbaea (Haifeng Liu 2021-04-02 08:16:24 +0000 1121)        int ret = 0;
eea587cbaea (Haifeng Liu 2021-04-02 08:16:24 +0000 1122)        unsigned int timeoutCounter = 0, recievedMsgCounter = 0;
eea587cbaea (Haifeng Liu 2021-04-02 08:16:24 +0000 1123)        bool recivedCorrectSuccessReply = false;

```

比如，我想查看当前文本 1117行以后的blame历史

1. !git blame -L 1117  %

   在vim中输入上述命令，就可以看到代码的blame历史， -L <start>, <end>  使用 -L 可以指定要显式的blame的代码行数范围，

   !git blame %  则查看当前文本全部blame历史，这时可以像vim中一样，输入行号，然后 gg 跳转到目标行也可以。

   %  在vim指的是当前文件的路径名称。

2. 通过上面的git blame只能看出是谁修改的，到底修改了什么不知道，这时可以再使用  git show commitid 来查看具体的修改内容。

## vim中使用Gtags -g 进行文本搜索时，匹配整个单词

Gtags -gM  pattern   

-M  表示匹配整个单词。



## vim代码折叠

zf 创建折叠

1   zc   折叠
2   zC   对所在范围内所有嵌套的折叠点进行折叠
3   zo   展开折叠
4   zO   对所在范围内所有嵌套的折叠点展开
5   [z    到当前打开的折叠的开始处。
6   ]z    到当前打开的折叠的末尾处。
7   zj    向下移动。到达下一个折叠的开始处。关闭的折叠也被计入。
8   zk   向上移动到前一折叠的结束处。关闭的折叠也被计入。



## vimdiff 使用

dp   将当前复制到对方

do  将对方复制到当前

## vimgrep 和copen使用

对于不确定位置的搜索和跳转，推荐使用 vimgrep 配合 copen ，这样的好处是：



1. 得到一个结果项清单，你可以通过这个清单直接进行跳转，也能直接利用清单中打印出来的行号
2. 通过目视一次性看到多个结果项，你不需要在正文中频繁跳转来查看那些项



用 vimgrep 对当前 buffer 进行查找：



```vim
:vimgrep /第\d\+话/ %
```

打开 quickfix 窗口：



```vim
:copen
```

然后你就能快速查看所有的结果项和进行跳转。



详细了解：

```text
:h vimgrep
:h copen
```

注： vimgrep的简写为vim， 在命令窗口，输入 :vim pattern  % 即可。

作者：zecy
链接：https://www.zhihu.com/question/30782510/answer/49737544
来源：知乎
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。



## quickfix-list 相关缩写

```
:cnext, :cn         # 当前页下一个结果
:cprevious, :cp     # 当前页上一个结果
:clist, :cl         # 使用 more 打开 Quickfix 窗口
:copen, :cope, :cw  # 打开 Quickfix 窗口，列出所有结果
:ccl[ose]           # 关闭 Quickfix 窗口。
```

参考：http://wxnacy.com/2017/10/13/vim-grep/

## 使用vimgrep 查询当前或指定目录

Gtags -g 只能进行全局的查看，如果仅仅查询当前文件或当前目录的话，可以使用vimgrep来解决。

:vim pattern %|copen

:vim pattern %:h/*|copen

如果想搜索指定类型 :vim pattern %:h/*.c|copen

```sh
多个指定类型  :vim pattern %:h/*.c %:h/*.h|copen
```

注： vimgrep的缩写为vim， vimgrep搜索结果默认不打开quickfix，可以使用 |copen 显式的打开。

## Tagbar插件使用说明

1. Tagbar 列表中，如果前面有一个减号‘-’的标志，表示其为static的。

2. 在Tagbar列列中，查看函数分为“跳转到函数”和“预览函数”

   在Tagbar中按回车，光标会跳转到函数的定义编辑窗口，而按下 p 键，则光标仍然在Tagbar列表窗口中。



## vim 修改点跳转与回退

Ctrl-O

Ctrl-I



g;  

g,



注： :h g;       