# ripgrep 使用技巧

## global 默认

global 默认是打印出要查找的符号(例如函数)所在的文件

global symbols

global - print locations of given symbols

global exec_simple_query
```sh
[uxdb@localhost ~/uxdb-ng/uxdb-2.0]$ global exec_simple_query
src/backend/tcop/uxdb.c
```

-x 可以显示出更加详细的信息
global -x exec_simple_query
```sh
[uxdb@localhost ~/uxdb-ng/uxdb-2.0]$ global -x exec_simple_query
exec_simple_query  885 src/backend/tcop/uxdb.c exec_simple_query(const char *query_string)
```

## global -r  和 global -rx

```sh
[uxdb@localhost ~/uxdb-ng/uxdb-2.0]$ global -r exec_simple_query
src/backend/tcop/uxdb.c
[uxdb@localhost ~/uxdb-ng/uxdb-2.0]$ global -rx exec_simple_query
exec_simple_query 4280 src/backend/tcop/uxdb.c 							exec_simple_query(query_string);
exec_simple_query 4283 src/backend/tcop/uxdb.c 						exec_simple_query(query_string);
[uxdb@localhost ~/uxdb-ng/uxdb-2.0]$ 
```

## 函数名称模糊搜索

global -c 会打印出所有的函数名称, 然后再使用grep 自由过滤
global -c|grep ".*bg.*worker.*"

```sh
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ global -c|grep ".*bg.*worker.*"
bg_worker_load_config
bgworker_die
bgworker_forkexec
bgworker_quickdie
bgworker_should_start_now
bgworker_sigusr1_handler
create_partitions_bg_worker_segment
create_partitions_for_value_bg_worker
do_start_bgworker
maybe_start_bgworkers
start_bgworker
start_bgworker_errmsg
```
然后, vi -t  maybe_start_bgworkers  就可以直接跳转到行数的定义除了.

## 查看指定xx.c中的所有函数

1 比如查找uxdb.c中的, 但不知道uxdb.c在当前目录的路径

global -P "uxdb.c"

```
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ global -P "uxdb.c"
src/backend/tcop/uxdb.c
src/backend/utils/rac/uxdb_cluster.c
src/backend/utils/rac/uxdb_cluster_heart_beat.c
src/include/utils/rac/uxdb_cluster.h
src/include/utils/rac/uxdb_cluster_heart_beat.h
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ 

```

global -P "\buxdb.c\b"

```
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ global -P "\buxdb.c\b"
src/backend/tcop/uxdb.c
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$
```
2 找到路径后, global -f 即可打印此文件内的所有符号

global -f src/backend/tcop/uxdb.c

##

global 

## gtags 只索引指定的文件

如果需要gtags只索引指定的文件, 可以先使用find查找出需要索引的文件列表, 然后保存到gtags指定
的gtags.files 文件中, 那么在执行 global -iv 或 global -uv 时, gtags则只为gtags.files中
指定的文件进行索引

find src -type f > gtags.files
