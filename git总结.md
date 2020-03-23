

## 

git 查看单个分支提交历史

邹小邹大厨
2018.07.20 17:41:42
字数 29
阅读 2,731
如果dev-webpack从dev切出来的
可以用
git log dev..dev-webpack
查看单独的dev-webpack提交历史

git log  dev...dev_branch


## 

git rebase -i HEAD~3
[detached HEAD 40d49ac76f] fix #66841: Uninitialized values(xactid) be used
 Date: Fri Jan 17 14:34:26 2020 +0800
 2 files changed, 22 insertions(+), 12 deletions(-)
Successfully rebased and updated refs/heads/bug/ver2.1.0.1r/#66841.
