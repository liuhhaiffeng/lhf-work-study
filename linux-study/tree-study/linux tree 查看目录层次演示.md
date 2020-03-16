# linux tree 查看目录层次演示

-L n:  如 -L 2 表示只打印2个层次的信息
--dirsfirst: 目录显示在前, 文件显示在后
-C 在文件和目录清单加上色彩，便于区分各种类型
-f 显示全路径

```sh
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ tree src/backend/storage/ -L 2 --dirsfirst -C |grep -vE "*.\.o$|Make|READ|*.\.txt$"
src/backend/storage/
├── buffer
│   ├── buf_init.c
│   ├── bufmgr.c
│   ├── buf_table.c
│   ├── freelist.c
│   ├── localbuf.c
├── file
│   ├── bfz.c
│   ├── buffile.c
│   ├── compress_nothing.c
│   ├── compress_zlib.c
│   ├── copydir.c
│   ├── fd.c
│   ├── gp_compress.c
│   ├── reinit.c
├── freespace
│   ├── freespace.c
│   ├── fsmpage.c
│   ├── indexfsm.c
├── ipc
│   ├── dsm.c
│   ├── dsm_impl.c
│   ├── ipc.c
│   ├── ipci.c
│   ├── latch.c
│   ├── pmsignal.c
│   ├── procarray.c
│   ├── procsignal.c
│   ├── shmem.c
│   ├── shm_mq.c
│   ├── shmqueue.c
│   ├── shm_toc.c
│   ├── sinvaladt.c
│   ├── sinval.c
│   ├── standby.c
├── large_object
│   ├── inv_api.c
├── lmgr
│   ├── condition_variable.c
│   ├── deadlock.c
│   ├── generate-lwlocknames.pl
│   ├── lmgr.c
│   ├── lock.c
│   ├── lwlock.c
│   ├── lwlocknames.c
│   ├── lwlocknames.h
│   ├── lwlocknames.txt
│   ├── predicate.c
│   ├── proc.c
│   ├── s_lock.c
│   ├── spin.c
├── page
│   ├── bufpage.c
│   ├── checksum.c
│   ├── itemptr.c
├── smgr
│   ├── encryption.c
│   ├── md.c
│   ├── smgr.c
│   ├── smgrtype.c
```

```
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ tree src/backend/storage/ -L 2 -f --dirsfirst -C |grep -vE "*.\.o$|Make|READ|*.\.txt$"
src/backend/storage
├── src/backend/storage/buffer
│   ├── src/backend/storage/buffer/buf_init.c
│   ├── src/backend/storage/buffer/bufmgr.c
│   ├── src/backend/storage/buffer/buf_table.c
│   ├── src/backend/storage/buffer/freelist.c
│   ├── src/backend/storage/buffer/localbuf.c
├── src/backend/storage/file
│   ├── src/backend/storage/file/bfz.c
│   ├── src/backend/storage/file/buffile.c
│   ├── src/backend/storage/file/compress_nothing.c
│   ├── src/backend/storage/file/compress_zlib.c
│   ├── src/backend/storage/file/copydir.c
│   ├── src/backend/storage/file/fd.c
│   ├── src/backend/storage/file/gp_compress.c
│   ├── src/backend/storage/file/reinit.c
├── src/backend/storage/freespace
│   ├── src/backend/storage/freespace/freespace.c
│   ├── src/backend/storage/freespace/fsmpage.c
│   ├── src/backend/storage/freespace/indexfsm.c
├── src/backend/storage/ipc
│   ├── src/backend/storage/ipc/dsm.c
│   ├── src/backend/storage/ipc/dsm_impl.c
│   ├── src/backend/storage/ipc/ipc.c
│   ├── src/backend/storage/ipc/ipci.c
│   ├── src/backend/storage/ipc/latch.c
│   ├── src/backend/storage/ipc/pmsignal.c
│   ├── src/backend/storage/ipc/procarray.c
│   ├── src/backend/storage/ipc/procsignal.c
│   ├── src/backend/storage/ipc/shmem.c
│   ├── src/backend/storage/ipc/shm_mq.c
│   ├── src/backend/storage/ipc/shmqueue.c
│   ├── src/backend/storage/ipc/shm_toc.c
│   ├── src/backend/storage/ipc/sinvaladt.c
│   ├── src/backend/storage/ipc/sinval.c
│   ├── src/backend/storage/ipc/standby.c
├── src/backend/storage/large_object
│   ├── src/backend/storage/large_object/inv_api.c
├── src/backend/storage/lmgr
│   ├── src/backend/storage/lmgr/condition_variable.c
│   ├── src/backend/storage/lmgr/deadlock.c
│   ├── src/backend/storage/lmgr/generate-lwlocknames.pl
│   ├── src/backend/storage/lmgr/lmgr.c
│   ├── src/backend/storage/lmgr/lock.c
│   ├── src/backend/storage/lmgr/lwlock.c
│   ├── src/backend/storage/lmgr/lwlocknames.c
│   ├── src/backend/storage/lmgr/lwlocknames.h
│   ├── src/backend/storage/lmgr/lwlocknames.txt
│   ├── src/backend/storage/lmgr/predicate.c
│   ├── src/backend/storage/lmgr/proc.c
│   ├── src/backend/storage/lmgr/s_lock.c
│   ├── src/backend/storage/lmgr/spin.c
├── src/backend/storage/page
│   ├── src/backend/storage/page/bufpage.c
│   ├── src/backend/storage/page/checksum.c
│   ├── src/backend/storage/page/itemptr.c
├── src/backend/storage/smgr
│   ├── src/backend/storage/smgr/encryption.c
│   ├── src/backend/storage/smgr/md.c
│   ├── src/backend/storage/smgr/smgr.c
│   ├── src/backend/storage/smgr/smgrtype.c

8 directories, 126 files
```


tree src/backend/storage/ -L 2 -f --dirsfirst -C  -d

-d  仅显示目录

## 说明

linux下tree命令详解---linux以树状图逐级列出目录的内容命令
##############################################################################################
命令格式
tree <选项或者是参数> <分区或者是目录>
##############################################################################################
(1) tree 最长使用的参数或者是选项
 
-a 显示所有文件和目录。
[root@liyao ~]# tree -a
.
|-- .bash_logout
|-- .bash_profile
|-- .bashrc
|-- .cshrc
|-- .gconf
|   `-- apps
|       |-- %gconf.xml
|       `-- gnome-session
|           |-- %gconf.xml
|           `-- options
|               `-- %gconf.xml
|-- .gconfd
|   `-- saved_state
|-- .tcshrc
|-- anaconda-ks.cfg
|-- install.log
`-- install.log.syslog
******************************************************************************************************************
-d 显示目录名称而非内容。
[root@liyao ~]# tree -d
.
`-- liyao
1 directory

******************************************************************************************************************
-f 在每个文件或目录之前，显示完整的相对路径名称。
[root@liyao ~]# tree -f
.
|-- ./anaconda-ks.cfg
|-- ./install.log
|-- ./install.log.syslog
`-- ./liyao
1 directory, 3 files
********************************************************************************************************************
-F 在执行文件，目录，Socket，符号连接，管道名称名称，各自加上"*","/","=","@","|"号。
[root@liyao ~]# tree -F
.
|-- anaconda-ks.cfg
|-- install.log
|-- install.log.syslog
`-- liyao/

1 directory, 3 files
*****************************************************************************************************************
-r 以相反次序排列
[root@liyao ~]# tree -r
.
|-- liyao
|-- install.log.syslog
|-- install.log
`-- anaconda-ks.cfg

1 directory, 3 files
****************************************************************************************************************
-t 用文件和目录的更改时间排序。

[root@liyao ~]# tree -t
.
|-- liyao
|-- anaconda-ks.cfg
|-- install.log
`-- install.log.syslog

1 directory, 3 files
[root@liyao ~]# ls -l
total 56
-rw------- 1 root root  1012 Jul  3 21:43 anaconda-ks.cfg
-rw-r--r-- 1 root root 27974 Jul  3 21:43 install.log
-rw-r--r-- 1 root root  4708 Jul  3 21:43 install.log.syslog
drwxr-xr-x 2 root root  4096 Jul  3 23:30 liyao
***********************************************************************************************************************
-L n 只显示 n 层目录 （n 为数字）
[root@liyao ~]# tree -L 2
.
|-- anaconda-ks.cfg
|-- install.log
|-- install.log.syslog
`-- liyao
    `-- baobao

2 directories, 3 files
*********************************************************************************************************************
--dirsfirst 目录显示在前文件显示在后
[root@liyao ~]# tree --dirsfirst
.
|-- liyao
|   `-- baobao
|-- anaconda-ks.cfg
|-- install.log
`-- install.log.syslog

2 directories, 3 files

####################################################################################################
(2) 可以加的参数，但是不是经常用得到
-A 使用ASNI绘图字符显示树状图而非以ASCII字符组合。
-C 在文件和目录清单加上色彩，便于区分各种类型。
-D 列出文件或目录的更改时间。
-g 列出文件或目录的所属群组名称，没有对应的名称时，则显示群组识别码。
-i 不以阶梯状列出文件或目录名称。
-I 不显示符合范本样式的文件或目录名称。
-l 如遇到性质为符号连接的目录，直接列出该连接所指向的原始目录。
-n 不在文件和目录清单加上色彩。
-N 直接列出文件和目录名称，包括控制字符。
-p 列出权限标示。
-P 只显示符合范本样式的文件或目录名称。
-q 用"?"号取代控制字符，列出文件和目录名称。
-s 列出文件或目录大小。
-u 列出文件或目录的拥有者名称，没有对应的名称时，则显示用户识别码。
-x 将范围局限在现行的文件系统中，若指定目录下的某些子目录，其存放于另一个文件系统上，则将该子目录予以排除在寻找范围外。


## 参考

[linux下tree命令详解](https://blog.csdn.net/joeblackzqq/article/details/7577974)