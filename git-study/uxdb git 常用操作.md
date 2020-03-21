# uxdb git 常用操作

本地分支修改暂存
git stash

本地分支切换
git checkout 本地分支名称

创建本地分支local_branch 并切换到local_branch分支
git checkout -b local_branch

查看本地分支
git branch

删除本地分支
git branch -d 本地分支名称

查看远程分支
git branch -a

删除远程分支
git push origin --delete 远程分支名称

## 参考

[git删除本地分支和远程分支](https://www.cnblogs.com/lwcode6/p/11084537.html)


更新代码
```
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ git pull
Username for 'https://cd.uxsino.com:10943': liuhaifeng
Password for 'https://liuhaifeng@cd.uxsino.com:10943': 
remote: Enumerating objects: 867, done.
remote: Counting objects: 100% (867/867), done.
remote: Compressing objects: 100% (322/322), done.
remote: Total 867 (delta 563), reused 809 (delta 540)
Receiving objects: 100% (867/867), 1.21 MiB | 1.76 MiB/s, done.
Resolving deltas: 100% (563/563), completed with 163 local objects.
From https://cd.uxsino.com:10943/db/uxdb-ng
 * [new branch]            bug/ver2.1.0.1s/#70632             -> origin/bug/ver2.1.0.1s/#70632
 + 9b137af277...5fc6206bf8 bug/ver2.1.0.2/#68627              -> origin/bug/ver2.1.0.2/#68627  (forced update)
 * [new branch]            changxinTestClientBoostThreaGroup  -> origin/changxinTestClientBoostThreaGroup
   6a08e85f90..715f383403  changxin_get_redisnodes_regularly  -> origin/changxin_get_redisnodes_regularly
   549820f0c0..e892688b75  ctr_ckk                            -> origin/ctr_ckk
 + 6ebdb131f7...bdc510ef61 feature/ver2.1.0.2/#66458          -> origin/feature/ver2.1.0.2/#66458  (forced update)
 * [new branch]            feature/ver2.1.1.0/#70250          -> origin/feature/ver2.1.1.0/#70250
 * [new branch]            feature/ver2.1.1.0/#70254          -> origin/feature/ver2.1.1.0/#70254
 * [new branch]            feature/ver2.1.1.0/#70364          -> origin/feature/ver2.1.1.0/#70364
 + 0c1ff5ff86...09582460e3 pg12.1_upgrade/#70471              -> origin/pg12.1_upgrade/#70471  (forced update)
   bc5be409c4..407ce4f1e4  pg12.1_upgrade/Compilation_problem -> origin/pg12.1_upgrade/Compilation_problem
   f212554d82..e943036cfc  rac3_debug_ly                      -> origin/rac3_debug_ly
 * [new branch]            security10_bug_#70584              -> origin/security10_bug_#70584
 * [new branch]            zhoucm_migration                   -> origin/zhoucm_migration
Already up to date.
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ 
```

git rebase
TODO

### 推送本地分支local_branch到远程分支 remote_branch并建立关联关系

      a.远程已有remote_branch分支并且已经关联本地分支local_branch且本地已经切换到local_branch

          git push

     b.远程已有remote_branch分支但未关联本地分支local_branch且本地已经切换到local_branch

         git push -u origin/remote_branch

     c.远程没有有remote_branch分支并，本地已经切换到local_branch

        git push origin local_branch:remote_branch
————————————————
版权声明：本文为CSDN博主「hijiankang」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/hijiankang/article/details/47254179

### 参考

[git 分支管理 推送本地分支到远程分支等](https://blog.csdn.net/hijiankang/article/details/47254179)


### git diff

git分支所有的修改的diff和patch
git diff
git diff > mypatch

仅当前目录下所有修改的diff和patch
git diff ./

git diff ./  > mypatch


### git reset 

git reset --hard  提交号

[GIT 如何删除某个本地的提交](https://www.cnblogs.com/slu182/p/4568227.html)


### git怎么删除某一次提交？

作者：Elpie Kay
链接：https://www.zhihu.com/question/324710274/answer/686174035
来源：知乎
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

像A-B-C这种比较简单的历史，要去掉B的话可以这样

git reset A --hard
git cherry-pick C

回退到A上然后把C再cherrypick过来，这样就把B给跳过了。

如果待处理的提交历史比较长，那用rebase -i更方便一些

git rebase -i A

这个命令以A为新的基准（base），将A之后的commit列出来让用户选择如何处理。在出现的编辑界面上，把B前面的pick改成d或者drop，或者把一整行删除掉，保存退出就可以了。

同样地，处理A1-B1-A2-B2，要删除B1的话

git reset A1 --hard
git cherry-pick A2 B2

或者

git rebase -i A1

把B1从编辑列表里删掉，保存退出。

第一个例子和第二个例子有个不同的地方，第一个例子里的commit都是本地还没推送的，这种可以随意整，整好了以后再推送，不会影响别人。第二个例子里，commit很可能都是已经推送到大家共用的中央仓库的，B1很可能已经被拉取到了其他人的本地仓库里。你这边将其删除后，需要用强制推送更新中央仓库里的分支，并且通知其他人这个变动，否则其他人很可能会将新旧版本的分支历史不经意间merge到一起再推送回中央仓库，导致B1没删掉还多了一个merge commit，将分支历史变得更加复杂了。编辑于 2019-05-17

刘磊
C: OCTEON & KERNEL
用rebase -i删除对应的commit即可。远程的话，要求远程仓库允许force push（non-fast-forward-push）


## git diff 比较指定文件的不同版本

格式:
git diff commitid1 commiid2 backend/uxmaster/uxmaster.c

示例:
git diff HEAD 028fee backend/uxmaster/uxmaster.c

## git diff 比较指定提交版本

格式: 
git diff commitid1 commiid2

示例:
git diff 669c4a2eea468e91876d7787fc2f44aa829d93d3 028feee4801cd8c8679414288b68c338e648088c

注: 当然, commiid可以不用写这么全, 前6位或前8位即可.

## 2个分支代码合并(merge)

格式:
git merge --no-ff 要合并的分支名称

## git add之后如何取消

git reset HEAD 可以全部恢复未提交状态

前言：在开发中，有时已经 add 的代码，想要取消恢复更改的文件，那么怎么办呢？

1、git checkout — //未git add的文件

2、git reset HEAD //已经git add的文件，可以用这个取消add，然后用上一条命令恢复

3、git reset –hard HEAD //把全部更改的文件都恢复（小心使用，不然辛辛苦苦写的全没了）

作者：小丶侯
链接：https://www.jianshu.com/p/3bc2fc01492b
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

## git push

```
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ git push
fatal: The upstream branch of your current branch does not match
the name of your current branch.  To push to the upstream branch
on the remote, use

    git push origin HEAD:bug/ver2.1.0.1r/#6735_for_devel

To push to the branch of the same name on the remote, use

    git push origin bug/ver2.1.0.1r/#67359_for_devel

To choose either option permanently, see push.default in 'git help config'.
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ 
uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ git push origin bug/ver2.1.0.1r/#67359_for_devel
Username for 'https://cd.uxsino.com:10943': liuhaifeng
Password for 'https://liuhaifeng@cd.uxsino.com:10943': 
To https://cd.uxsino.com:10943/db/uxdb-ng.git
 ! [rejected]              bug/ver2.1.0.1r/#67359_for_devel -> bug/ver2.1.0.1r/#67359_for_devel (non-fast-forward)
error: failed to push some refs to 'https://cd.uxsino.com:10943/db/uxdb-ng.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. Integrate the remote changes (e.g.
hint: 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ git pull
Username for 'https://cd.uxsino.com:10943': liuhaifeng
Password for 'https://liuhaifeng@cd.uxsino.com:10943': 
remote: Enumerating objects: 718, done.
remote: Counting objects: 100% (718/718), done.
remote: Compressing objects: 100% (363/363), done.
remote: Total 718 (delta 331), reused 655 (delta 322)
Receiving objects: 100% (718/718), 1.49 MiB | 6.54 MiB/s, done.
Resolving deltas: 100% (331/331), completed with 89 local objects.
From https://cd.uxsino.com:10943/db/uxdb-ng
   30038b5440..b1609c580f  bug/ver2.1.0.2/#69440                  -> origin/bug/ver2.1.0.2/#69440
   e892688b75..d94286366e  ctr_ckk                                -> origin/ctr_ckk
   f482d4e817..88703e039b  feature/ver2.1.1.0/#70250              -> origin/feature/ver2.1.1.0/#70250
   0070b79b74..36ecaed527  master                                 -> origin/master
   154cb566b2..aa1632789b  pg12.1_rebrand                         -> origin/pg12.1_rebrand
 * [new branch]            pg12.1_upgrade/#68439_postgres_adaptor -> origin/pg12.1_upgrade/#68439_postgres_adaptor
   67d1158f25..ff5ca56572  pg12.1_upgrade/#70353                  -> origin/pg12.1_upgrade/#70353
 + 09582460e3...eae6e3b1c2 pg12.1_upgrade/#70471                  -> origin/pg12.1_upgrade/#70471  (forced update)
   407ce4f1e4..44ef62d237  pg12.1_upgrade/Compilation_problem     -> origin/pg12.1_upgrade/Compilation_problem
 * [new branch]            security10_bug_#70629                  -> origin/security10_bug_#70629
 * [new branch]            uxdb_rac_devel_aut                     -> origin/uxdb_rac_devel_aut
   b130612ffc..d7c79c8ee5  wangqian_#70111                        -> origin/wangqian_#70111
Your configuration specifies to merge with the ref 'refs/heads/bug/ver2.1.0.1r/#6735_for_devel'
from the remote, but no such ref was fetched.
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ git log
commit 4a4f79ef778e40f3c65e3e23e52f16ec46fed9a6 (HEAD -> bug/ver2.1.0.1r/#67359_for_devel)
Author: liuhhaiffeng <liuhhaiffeng@163.com>
Date:   Tue Mar 17 18:45:20 2020 +0800

    fix #67359 for uxdb_rac_devel

commit 028feee4801cd8c8679414288b68c338e648088c (origin/uxdb_rac_devel)
Merge: 516ed86b26 957f8bc5cf
Author: Jian Zhao <zhaojian@uxsino.com>
Date:   Mon Mar 16 01:42:55 2020 +0000

    Merge branch 'feature/ver2.1.0.1/#61615' into 'uxdb_rac_devel'
    
    #61615: thread modification process: syssync, rpc fsm
    
    See merge request db/uxdb-ng!1371

commit 516ed86b267302f2a66f0937e7aeda89b6f1eb43
Merge: ec72ba6588 8d69bc143b
Author: Jian Zhao <zhaojian@uxsino.com>
Date:   Mon Mar 16 01:38:59 2020 +0000

    Merge branch 'feature/ver2.1.0.2/#57853' into 'uxdb_rac_devel'
    
    #57853 rac global oid feature added
    
    See merge request db/uxdb-ng!1362

commit ec72ba6588099874f6e9b2e7e91253c4e9c8426f (origin/uxdb_rac_devel_unittest_framework)
Author: zhaojian <zhaojian@uxsino.com>
Date:   Thu Mar 12 05:58:47 2020 -0400

    #57833 devel-self verification problem -- when lrmd boot failure, crm processes still alive that is not expected

commit 77d3b674b166f23c8f7439153a2659325dbd5b1c
Author: zhaojian <zhaojian@uxsino.com>
Date:   Tue Mar 10 00:40:11 2020 -0400

    how to make uxdb developing environment for a fresher of uxdb

commit 5eb47c27f109e543913b5ab583d51c0e581b62ee
Author: zhaojian <zhaojian@uxsino.com>
Date:   Tue Mar 10 00:09:53 2020 -0400

    how to make uxdb developing environment for a fresher of uxdb

commit 27711652f3f3d8e8c5e9274d792392ecb3563b75
Author: zhaojian <zhaojian@uxsino.com>
Date:   Tue Mar 10 00:06:38 2020 -0400

```


再次重试, 还是不成功
```
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ git push origin bug/ver2.1.0.1r/#67359_for_devel
Username for 'https://cd.uxsino.com:10943': liuhaifeng
Password for 'https://liuhaifeng@cd.uxsino.com:10943': 
To https://cd.uxsino.com:10943/db/uxdb-ng.git
 ! [rejected]              bug/ver2.1.0.1r/#67359_for_devel -> bug/ver2.1.0.1r/#67359_for_devel (non-fast-forward)
error: failed to push some refs to 'https://cd.uxsino.com:10943/db/uxdb-ng.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. Integrate the remote changes (e.g.
hint: 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ 
```

## 之前上传的远程分支有问题, 将其删除,
然后再push, 可以发现, push是能够自动创建远程的同名分支
```
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ git push origin --delete bug/ver2.1.0.1r/#67359_for_devel
Username for 'https://cd.uxsino.com:10943': liuhaifeng
Password for 'https://liuhaifeng@cd.uxsino.com:10943': 
To https://cd.uxsino.com:10943/db/uxdb-ng.git
 - [deleted]               bug/ver2.1.0.1r/#67359_for_devel
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ git push origin bug/ver2.1.0.1r/#67359_for_devel
Username for 'https://cd.uxsino.com:10943': liuhaifeng
Password for 'https://liuhaifeng@cd.uxsino.com:10943': 
Counting objects: 7, done.
Delta compression using up to 2 threads.
Compressing objects: 100% (7/7), done.
Writing objects: 100% (7/7), 900 bytes | 900.00 KiB/s, done.
Total 7 (delta 6), reused 0 (delta 0)
remote: 
remote: To create a merge request for bug/ver2.1.0.1r/#67359_for_devel, visit:
remote:   https://gitlab.uxsino.com/db/uxdb-ng/merge_requests/new?merge_request%5Bsource_branch%5D=bug%2Fver2.1.0.1r%2F%2367359_for_devel
remote: 
To https://cd.uxsino.com:10943/db/uxdb-ng.git
 * [new branch]            bug/ver2.1.0.1r/#67359_for_devel -> bug/ver2.1.0.1r/#67359_for_devel
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ 
```

## Git diff 使用 vimdiff 对比差异

在Ubuntu中使用Git时，可使用命令行的git diff命令来对比两次提交的差异，但是这种对比查看方式无法直观地查看修改的差异，在对比和查看时不太方便。

可以使用vimdiff作为Git diff的对比工具，这样就方便了许多，Git的配置方法如下：

        $  git config --global diff.tool vimdiff

        $  git config --global difftool.prompt false

        $  git config --global alias.d difftool

配置完成后，可使用命令 "git d  <commit1> <commit2>" 时就会重定向到vimdiff，vimdiff的使用方法请看博客《使用 vimdiff 比较文件的技巧》，链接地址：https://blog.csdn.net/sean_8180/article/details/82560495
————————————————
版权声明：本文为CSDN博主「CodeApe123」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/sean_8180/article/details/82285964

lhf_ps: 上面3个步骤都要执行才会生效.

## git rebase

[聊下 git rebase -i](https://www.cnblogs.com/wangiqngpei557/p/5989292.html)


## 撤销 git add

git reset HEAD

## git push

格式

git push --set-upstream origin 远程分支名称

示例

```
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0/src/backend/uxmaster]$ git push
fatal: The current branch bug/ver2.1.0.1r/#67004_#67020_#70991 has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin bug/ver2.1.0.1r/#67004_#67020_#70991

[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0/src/backend/uxmaster]$ 
```

### --set-upstream (暴力推送)


分析：
git分支与远程主机存在对应分支，可能是单个可能是多个。 

simple方式：如果当前分支只有一个追踪分支，那么git push origin到主机时，可以省略主机名。 

matching方式：如果当前分支与多个主机存在追踪关系，那么git push --set-upstream origin master（省略形式为：git push -u origin master）将本地的master分支推送到origin主机（--set-upstream选项会指定一个默认主机），同时指定该主机为默认主机，后面使用可以不加任何参数使用git push。

注意：
Git 2.0版本之前，默认采用matching方法，现在改为默认采用simple方式。

lhf_ps: 即如果本地推送的分支在远端还没有创建, 使用git push --set-upstream origin master（省略形式为：git push -u origin master）, 可以在推送的同时在远端创建此分支.

#### 参考: 
[git push时提示--set-upstream](https://www.cnblogs.com/blog-yuesheng521/p/10670778.html)

## 查看远程分支的仓库地址

git remote -v