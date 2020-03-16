# ripgrep 使用技巧

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
