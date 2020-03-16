
## grep 实现vscode ctrl+shift+f 全局查找功能

目标:  查找 PostmasterMain(  字符串, 正则要求:
1) 以PostmasterMain为单词的开头,  故使用  \b  正则来界定,  因为在 \ 为正则的关键字, 所以实际要写成 \\b
   注意: \\bPostmasterMain  和 ^PostmasterMain 的不同, 前者只是界定单词的开始, 后者界定行首

所有文件查找
grep -r  \\bPostmasterMain\(
find|xargs grep \\bPostmasterMain\(

所有*.c文件中查找
grep -r  \\bPostmasterMain\(   --include="*.c"   
find -name *.c|xargs grep \\bPostmasterMain\(

所有*c和*.h文件中查找
grep -r  \\bPostmasterMain\(   --include="*.c" --include="*.h"
find -name *.[ch]|xargs grep \\bPostmasterMain\(

除过*.c之外的所有文件中查找
grep -r  \\bPostmasterMain\(   --exclude="*.c" 

除过*.c和*.h之外的所有文件中查找
grep -r  \\bPostmasterMain\(   --exclude="*.c" --exclude="*.h"

### 参考

[grep -r](https://blog.csdn.net/yongan1006/article/details/8134401)

### grep -r 和 grep -R 的区别
-r, --recursive
              Read all files under each directory, recursively, following symbolic links only if they are on the command line.  This is equivalent
              to the -d recurse option.

-R, --dereference-recursive
              Read all files under each directory, recursively.  Follow all symbolic links, unlike -r.

看起来, grep -R 的搜索范围比grep -r要大一些




