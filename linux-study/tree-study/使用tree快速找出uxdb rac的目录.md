
## 使用tree快速找出uxdb rac的目录

因为tree -d 只会列出目录的名称, 所以再使用grep rac 过滤一下, 就可以找出 uxdb rac的目录了.
```
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ tree src/ -L 3 -d -f|grep rac
│   │   ├── src/backend/utils/rac
│       └── src/backend/uxmaster/uxdb_rac
│   │   └── src/include/utils/rac
│       └── src/include/uxmaster/uxdb_rac
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ 
```

```
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ tree src/ -L 4 -d -f|grep rac
│   │   ├── src/backend/utils/rac
│   │   │   ├── src/backend/utils/rac/cpp
│   │   │   ├── src/backend/utils/rac/grd
│   │   │   └── src/backend/utils/rac/lock_free_queue
│       └── src/backend/uxmaster/uxdb_rac
│   │   └── src/include/utils/rac
│   │       ├── src/include/utils/rac/grd
│   │       ├── src/include/utils/rac/lock_free_queue
│   │       └── src/include/utils/rac/socket
│       └── src/include/uxmaster/uxdb_rac
    │       └── src/xactd/brpc-0.9.5/tools/trackme_server
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ 
```

## 列出uxdb rac目录下的所有源码文件 (但不要列出其中的 *.o, *.txt, Makefile文件)

说明: 

这里要使用 |grep -v, exclude排除法;  而不是 |grep -E "\.c" 包含法, 因为"include 包含法"
会打断目录的层级显示.

在grep 中如果有多个过滤选项, 可以用 |  来分隔, 但必须添加参数 -E, 否则grep不识别.
grep -vE "\.o$|\.txt|Makefile"


```
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ tree src/backend/utils/rac|grep -vE "\.o$|\.txt|Makefile"
src/backend/utils/rac
├── cpp
│   ├── blockreq_map.cpp
│   ├── disconn_map.cpp
│   ├── localwlock_map.cpp
│   ├── node_desc.cpp
│   ├── socket_map.cpp
│   ├── table_block_nlock.cpp
│   ├── table_pos_map.cpp
│   ├── xact_set.cpp
├── grd
│   ├── cluster_node_recovery.c
│   ├── grd.c
│   ├── grd_listen.c
│   ├── uxsql_blockreq_record.c
├── lock_free_queue
│   ├── array_spsc_queue.c
│   ├── block_locker.c
│   ├── cachesync_queue.c
│   ├── fsm_vm_conn_pool.c
│   ├── grd_fault_queue.c
│   ├── grd_request_queue.c
│   ├── grd_response_queue.c
│   ├── grd_vm_and_fsm_queue.c
│   ├── heartbeat_activenode_queue.c
│   ├── heartbeat_response_queue.c
│   ├── mpsc_queue.c
│   ├── rac_queue.c
│   ├── send_queues.c
│   ├── spsc_queue.c
│   ├── uxsql_queue_array.c
├── uxdb_cluster.c
├── uxdb_cluster.conf.sample
├── uxdb_cluster_heart_beat.c
├── uxdb_rac.c

3 directories, 71 files
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]
```