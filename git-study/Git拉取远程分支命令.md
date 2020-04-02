
Git拉取远程分支命令
https://www.cnblogs.com/rainboy2010/p/11666255.html

如果我们想从Git仓库中拉取一个分支到本地，此处假如远程分支为develop,本地要创建的分支为dev,可以使用以下命令:

git init    //初始化本地Git仓库

git remote add origin https://xxx.git  //将本地仓库和远程仓库相关联

git fetch origin develop

**git checkout -b dev origin/develop //在本地创建分支dev，并将远程分支develop的信息同步到本地分支dev**

这样我们就拉取了远程分支的内容了

其他命令：

查看远程分支信息：git branch -a

推送分支到远程: git push origin HEAD:develop

删除远程分支：git push origin --delete develop