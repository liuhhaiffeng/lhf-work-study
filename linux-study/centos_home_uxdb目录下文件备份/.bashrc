# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

export GIT_SSL_NO_VERIFY=true
export M3_HOME=/usr/local/maven3
export GRADLE=/usr/local/gradle/gradle-4.6
export UXHOME=/home/uxdb/uxdbinstall/dbsql

#export UXSRCHOME=/home/uxdb/uxdb-ng/uxdb-2.0
export UXSRCHOME=/home/uxdb/uxdb-ng-rac/uxdb-2.0
#export UXSRCHOME=/home/uxdb/uxdb-ng_branch_s/uxdb-2.0

export PGSRCHOME=/home/uxdb/postgresql-10.10

export UXMPPSRC=$UXSRCHOME/contrib/uxmpp/src
export UXMPPDIST=$UXSRCHOME/contrib/uxmpp/src/backend/distributed
export GREPFILTER="citus"      # grepc, grepwc等的过滤项目 格式如下: "过滤项1|过滤项2|过滤项3"
export MYPREFIX1="+++++++++++++++++++++++++++++++++++++++++++++++"
export MYPREFIX2="-----------------------------------------------"

PATH=$PATH:$HOME/bin:$UXHOME/bin:$UXPOOLHOME/bin:$M3_HOME/bin:$GRADLE/bin:$HOME/.myscript:$UXHOME/../xactd/bin:$HOME/ractest
export PATH

# gdb edit时, 使用vim, 而非vi
EDITOR=/usr/bin/vim
export EDITOR

alias ux_bin='cd $UXHOME/bin'
alias ux_xa='cd $UXHOME/../xactd'
alias ux_xa_inst='cd $UXHOME/../xactd/instances'
alias ux_xa_bin='cd $UXHOME/../xactd/bin'
alias ux_install='cd $UXHOME/..'
alias uxsrc='cd $UXSRCHOME'
alias uxsrclhf='cd $UXSRCHOME/lhf_rac_code'
alias uxmppmake='cd $UXSRCHOME/contrib/uxmpp'
alias uxmppsrc='cd $UXSRCHOME/contrib/uxmpp/src/backend/distributed'
alias pc='cd ~/sql92原始程序各家自己编译_for_uxsino_3/v6pcisql/pc'
alias uxsqlsrc='cd $UXSRCHOME/src/bin/uxsql'
alias uxdumpsrc='cd $UXSRCHOME/src/bin/ux_dump'
alias lc='ls *.c*'   # .c .cpp .cxx
alias lh='ls *.h*'   # .h .hpp .hxx
alias lhc='ls *.[hc]*' 

alias uxrac='cd $HOME/cluster_dir_rac'
alias uxxactd='cd $UXHOME/uxdb-ng-rac/scripts/xactd/xactd/bin'
alias gl='cd $UXSRCHOME;global'

# 在shell脚本中使用grepc或grepwc,搜索关键字没有高亮,添加如下环境变量后, source即可生效
export GREP_OPTIONS="--color=auto"
# 刘海峰自定义的tmpfile, tmpfile2,tmpfile3
export tmp=/tmp/lhf_tmp_file
export tmp2=/tmp/lhf_tmp_file2
export tmp3=/tmp/lhf_tmp_file3
# ---

export UXDATA=/home/uxdb/cluster_dir_uxmpp/local_uxmpp

export CURUXDBDIR=$HOME/s63632
export CURUXDBNAME=mdb3


# uxdb rac 
# +++++++++++++++++++++++++++++++++
export PATH=/home/uxdb/automake_cmake_for_uxdb_rac/automake-1.15:$PATH
export PATH=/home/uxdb/automake_cmake_for_uxdb_rac/automake-1.15/bin:$PATH
export PATH=/home/uxdb/automake_cmake_for_uxdb_rac/cmake:$PATH
export PATH=/home/uxdb/automake_cmake_for_uxdb_rac/cmake/bin:$PATH
# ---------------------------------


export RAC_CLUSTER_DIR="$HOME/cluster_dir_rac"
export RAC_CLUSTER_NAME="xactd4"

# [\u@\h \W]\$  注意: \$ 后面还有个空格
# 注意: 这里要用单引号包括起来, 通过测试发现, 如果使用双引号包括的话, 当由uxdb用户
#       切换到root用户后, 后面的美元符号($)没有变化, 而使用单引号包括的话, 
#        会变成正确的井号(#)
# export PS1="[*** \u@\h \W]\$ "
#export PS1='[+++ \u@\h \W]\$ '
# 带颜色设置的, 参考: https://www.cnblogs.com/Q--T/p/5394993.html
#export PS1='\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[36;40m\]\w\[\e[0m\]]\\$ '
export PS1='\[\e[37;43m\][\[\e[32;43m\]\u\[\e[37;40m\]@\h \[\e[36;40m\]\w\[\e[0m\]]\\$ '
