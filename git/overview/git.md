1.MarkDown:可以使用普通文本编辑器编写的标记语言，通过简单的标记使普通文本内容

具有一定的格式

2.集中式版本控制系统和分布式

3.git的安装和初始化

git config --global user.name ""

git config --global user.email ""

4.创建本地仓库：git init

5.git add <file>  git commit -m ""

6.git status

7.git log  git  log --pretty=oneline查看commit的日志

8.HEAD表示当前版本,HEAD^  HEAD^^ HEAD~100向上回退多少版本

9.git reset --hard HEAD^ (回退版本时暂存区的修改会被丢弃)

10.git reflog记录每一条命令

11.隐藏目录git是版本库，暂存区，为我们自动创建第一个分支master，以及指向master的指针HEAD

12.git commit 只负责提交暂存区的内容，没有add的修改不会被提交

13.git diff HEAD --  git.md 查看版本库和工作区的差别

14.git checkout -- file 撤回工作区的修改，撤回暂存区的修改

15.git reset HEAD <file> 也能撤回暂存区的修改

16.git rm 然后git commit

可以使用git checkout -- file 将版本库中最新的内容更新到工作区

17.使用git推送到远程服务器：配置完ssh公钥之后，需要在本地库添加

git remote add origin git@github.com:dmzc/test1.git

git push -u origin master

18.从远程库克隆：

git clone git@github.com:dmzc/test1.git

git支持多种协议，默认的git协议支持ssh，https慢而且每次需要口令

19.主分支master：head指向分支，分支才指向提交

git checkout -b dev切换分支并提交 === git branch dev  和git checkout dev（git switch 也可以）

git branch 列出所有分支

git branch -d dev删除分支

git log --graph  分支合并图

20.分支策略：

master分支应该非常稳定，平时工作都在dev分支，合并分支时默认fast forward合并，--no-of参数使用普通模式合并，

合并后的历史有分支

git stash list     git stash apply    git stash drop  暂时隐藏和重新恢复工作区的修改

git cherry-pick  4c6456r  从某次提交更新当前分支

**关于这些对于分支同步的操作？？？？

丢弃一个没有进行合并的分支 git branch -D <name>原来是d

21.git remote -v显示远程库

22.master是主分支需要时刻与远程同步，dev是开发分支，也需要，其余的根据需要

23.建立本地分支和远程分支的关联

24.标签管理：标签与某个commit关联

git tag   可以给某个commit打上一个标签 

25.推送标签到远程   


26.使用码云--国内的Git托管服务

当关联远程服务器时，需要先删除本地仓库与github的关联

可以为一个git仓库建立两个远程仓库

27.git config --global color.ui true

.gitignore文件

配置别名
git config --global alias.<name>  "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

28.本地配置 .git/config文件

29.自建git服务器

30.git pull origin master 更新最新版本到本地仓库

//git更深层次的学习和探讨


git的痛点，git在不同场景中的应用和最佳实践，git的学习程度

c
1.git中 .git文件各文件的内容和含义

    HEAD文件的内容?

    config文件的内容？

    refs文件的内容？

    objects文件夹的内容？

    git cat-file -t   git cat-file -p

    tree blob commit  三种类型之间的关系？

    三种类型之间的关系?

    新建文件  、把文件加入暂存区 、 commit文件会对.git目录产生那些影响？


2.gitk中author和commiter的概念



3.分离头指针的概念

切换到某个commit，此时这个commit的内容没有分支

此时没有挂勾到某个分支，如果切换会丢弃在某个commit修改的内容

分离头指针的状态下，HEAD指定到某一次具体的commit


4.不同状态下，HEAD的指向内容

全部都commit，head指向什么？

HEAD指向分支还是commit？


5.删除某一个分支










