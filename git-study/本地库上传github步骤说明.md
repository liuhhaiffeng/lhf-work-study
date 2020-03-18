# 本地库上传github步骤说明

1 如果github上没有repository, 则先在github创建你的repository
2 如下说明

…or create a new repository on the command line
echo "# lhf-work-study" >> README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin https://github.com/liuhhaiffeng/lhf-work-study.git
git push -u origin master

…or push an existing repository from the command line
git remote add origin https://github.com/liuhhaiffeng/lhf-work-study.git
git push -u origin master

…or import code from another repository
You can initialize this repository with code from a Subversion, Mercurial, or TFS project.
Import code

3 注意事项

git push -u origin master
提示输入Username, 这里有一个坑, 应该填写的是你的github的邮箱地址, 而非github的用户名.