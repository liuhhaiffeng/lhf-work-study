# git merge冲突解决



## rebase的方法

1. git checkout  分支

2. git rebase 本地主线  

   或者

   git rebae origin/主线

   3. 如果有冲突, 则解决冲突

   4. git add  解决了冲突的文件

   5. git rebase --continue      # 表示 git rebase finished

      如果想反悔, 也可以执行 git rebase --abort  # 表示撤销此次rebase

      6. 如果修改过冲突则执行 git commit
      7. 执行git push, 如果无法成功, git push -f

      

      ## 参考

      把主线代码合入自己的分支，使用rebase
      git rebase origin/rac_recovery_iterator3
      有冲突，修改冲突，修改后
      git add
      然后继续rebase
      git rebase --continue
      对于rac_recovery_iterator3不需要合过来的文件
      git rebase --skip
      最后，如果修改过冲突则执行 git commit,否则，直接执行 git push，要加-f,否则无法push

      

      





## merge的方法

TODO



## 其他

git reflog   查看rebase log



git reset --hard HEAD              # 对一次commit的reset

git reset --hard HEAD@{2}      # 一次commit中可能分为几个部分,  HEAD@{number}, 可以进行更加细致的reset,   HEAD@{number}   git log是查看不到的, 要使用git reflog来查看



