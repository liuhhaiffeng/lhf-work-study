# git add 后如何撤销？

mail-mail 2019-08-22 11:17:53  12347  收藏 2
分类专栏： sourcetree学习教程
版权
git add 操作时，有时会误添加一些不想提交的文件，如何解决？
1、误add单个文件
git reset HEAD 将file退回到unstage区
2、误add多个文件，只撤销部分文件
git reset HEAD 将file退回到unstage区

git rm 与 git reset的区别
git rm：用于从工作区和索引中删除文件
git reset：用于将当前HEAD复位到指定状态。一般用于撤消之前的一些操作(如：git add,git commit等)。

git rm file_path 删除暂存区和分支上的文件，同时工作区也不需要
git rm --cached file_path 删除暂存区或分支上的文件, 但工作区需要使用, 只是不希望被版本控制（适用于已经被git add,但是又想撤销的情况）
git reset HEAD 回退暂存区里的文件
————————————————
版权声明：本文为CSDN博主「mail-mail」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/crjmail/article/details/100011063