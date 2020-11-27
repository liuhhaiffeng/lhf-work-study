## sys data sync



- 刘遥10:18

  sys data sync这个，就是一个子进程一直循环接收 SI消息，然后写入本地共享内存。这个单元测试怎么写，手动添加创建共享内存这些，然后给发消息？

  周春妙

- 我觉得这个进程好像没有什么需要测的
  - - 刘遥

- 刘遥

  我也觉得没啥测的

## 影子信息

李垠@7月6日 18:38

影子信息不太明白：设计初衷，产生/清除时机，作用



周春妙:

![image-20200707102938235](D:\新人资料\lhf-work-study\PostgreSQL-study\image-20200707102938235.png)

周春妙

可以看一下这个图，这个是我之前转正时画的一个图，可以帮助看懂队列和消息转发流程



赵健

[@李垠](app://desktop.dingtalk.com/web_content/chatbox.html?isFourColumnMode=false#) 影子信息，是作为运行实例对自己已经持有的分布式锁信息的进一步抽象，某个实例下线后，即是用其他在线实例的影子信息重构和恢复dlm内部的grd管控信息，这个在会议中已经多次澄清



董建国: ReplyBlockRequest 函数 谁帮 讲解下 输出个 流程 文档
董建国: 太多if else嵌套  看不明白这个函数
李垠: [图片]

![image-20200707103427797](D:\新人资料\lhf-work-study\PostgreSQL-study\image-20200707103427797.png)李垠: 总结过一个



董建国: GetShadowInformation这个函数 影子信息 如果不在 ShadowInformations里，找个新的不用的位置后，新影子信息里各字段 如何填充的？
董建国: 我看代码 没看清楚， 
曹宝峰: pcm_bufinit.c里有
董建国: 这个文件里是 初始化 默认值
曹宝峰: GetShadowInformation最下面有

董建国: 	buf->tag = newTag;
	grd_get_epoch(&(buf->epoch));
	buf->is_recent_writer = false;
	buf->busy = true;
董建国: 这块为啥填true
曹宝峰: 那你知道busy是干什么的嘛
曹宝峰: 你知道is_recent_writer是干什么的嘛
董建国: 我感觉 这块 影子信息 应该从tag的管理者 那块获取。
曹宝峰: 管理者管理授权信息，就是所有实例请求锁的信息；影子信息保存自身持有的锁信息，就是自己持有什么锁





## CRM

董建国: 管理者实例故障挂掉，存活实例 执行GetManagerId 获取挂掉实例管理的pcm资源的管理者实例id    GetManagerId会执行超时 失败不
张争: 不会  资源会迁移到新的管理实例  迁移和冻结过程很短
董建国: 异常挂掉  我前几周测试 不会触发 资源迁移
董建国: 实例退出 可以触发 资源迁移
赵健: @董建国 异常挂掉还没实现
董建国: 异常挂掉时 执行 GetManagerId 获取 异常挂掉实例管理的资源的管理者 是不是会 失败
赵健: 后半段处理相同，不同在故障的识别，确定故障后，走实例离开流程



## 异常处理

董建国: 这块 PCM_REQUEST 请求超时后  ReadBuffer_common这个函数执行 是不是会 跳转到 sigsetjmp(local_sigjmp_buf, 1) 设置的位置
曹宝峰: ERROR  会跳到sigsetjmp





## MESSAGE_TYPE 消息



董建国: 有没有 介绍 MESSAGE_TYPE 消息 交互流程的文档
董建国: 	PCM_CANCEL_BUSY_REQUEST = 13,
	PCM_STAT_REQUEST = 14,
	PCM_STAT_REPLY = 15,

	// -------- Msg for grd recovery procedure
	FAULT_NODE_CLEAR = 17,
	MAX_PCM_REQUEST_MESSAGE = 99,


	// GRD Control thread's messages
	PCM_LOAD_GUIDE = 101,
	PCM_RESPONSE = 102,
陈坤坤: svn://192.29.1.2/svn/uxdb/10.团队建设/01.新员工/01.总结心得/rac多节点在vmware共享文件夹中初始化集群目录配置-陈坤坤.docx



## 代码规范


曹宝峰

svn://192.29.1.2/svn/uxdb/10.团队建设/02.规范文档/01.公司代码规范/C编码规范_西安研发.xls



## wal日志



曹宝峰6月24日 15:45

这个博客，源码解读，WAL这部分很详细
http://blog.itpub.net/search/blog/?type=blog&keyword=WAL%23

恢复部分可能得把这部分全部搞清楚，xlog中加一个字段，都可能影响位偏移，导致恢复出错





## 测试问题



曹宝峰: rac多机，配置ok，启动ok，节点1得到的master一直是1，节点2得到的master一直是2
张争: master 定位有问题？
曹宝峰: 我再试试



## 问题解决

uxdb_rac_devel_iterate3 分支, 编译的程序.
启动实例1 失败
./ux_ctl -D racdata -o "-c uxdb_rac=on -c instance_id=1 -p 5432" start

报错如下:
could not fork ClusterSyncConf process: Cannot allocate memory.

有人知道是怎么回事不?

![image-20200707104217766](D:\新人资料\lhf-work-study\PostgreSQL-study\image-20200707104217766.png)

董建国: 我没用最新代码，没有这个问题。
焦兰兰: 60659 open("/proc/meminfo", O_RDONLY)   = 8
60659 fstat(8, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
60659 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f09f0376000
60659 read(8, "MemTotal:        5573340 kB\nMemFree:          724904 kB\nMemAvailable:    4666084 kB\nBuffers:               0 kB\nCached:          4094272 kB\nSwapCached:         2504 kB\nActive:          2092900 kB\nInactive:        2247336 kB\nActive(anon):      53908 kB\nInactive(anon):   235496 kB\nActive(file):    2038992 kB\nInactive(file):  2011840 kB\nUnevictable:      114476 kB\nMlocked:          114476 kB\nSwapTotal:       2097148 kB\nSwapFree:        2066032 kB\nDirty:               156 kB\nWriteback:             0 kB\nAnonPages:        358108 kB\nMapped:            55876 kB\nShmem:             39644 kB\nSlab:             264380 kB\nSReclaimable:     186704 kB\nSUnreclaim:        77676 kB\nKernelStack:        6976 kB\nPageTables:        17708 kB\nNFS_Unstable:          0 kB\nBounce:                0 kB\nWritebackTmp:          0 kB\nCommitLimit:     4883816 kB\nCommitted_AS:    2053448 kB\nVmallocTotal:   34359738367 kB\nVmallocUsed:      191188 kB\nVmallocChunk:   34359310332 kB\nHardwareCorrupted:     0 kB\nAnonHugePages:     81920 kB\nHugePages_", 1024) = 1024
60659 read(8, "Total:       0\nHugePages_Free:        0\nHugePages_Rsvd:        0\nHugePages_Surp:        0\nHugepagesize:       2048 kB\nDirectMap4k:      112448 kB\nDirectMap2M:     2672640 kB\nDirectMap1G:     3145728 kB\n", 1024) = 202
60659 close(8)                          = 0
60659 munmap(0x7f09f0376000, 4096)      = 0
60659 mmap(NULL, 394264576, PROT_READ|PROT_WRITE, MAP_SHARED|MAP_ANONYMOUS|MAP_HUGETLB, -1, 0) = -1 ENOMEM (Cannot allocate memory)
60659 mmap(NULL, 394174464, PROT_READ|PROT_WRITE, MAP_SHARED|MAP_ANONYMOUS, -1, 0) = 0x7f09ca2ed000

周春妙: 看一下/proc/sys/vm/max_map_count参数
周春妙: [分享]http://192.29.1.2/uxdb/uxdbdoc/%E4%BC%98%E7%82%AB%E6%95%B0%E6%8D%AE%E5%BA%93%E7%94%A8%E6%88%B7%E6%89%8B%E5%86%8C%20V2.1/html/kernel-resources.html
刘海峰: sysctl 中 vm.overcommit_memory 的含义
https://www.cnblogs.com/xianbei/archive/2012/11/23/2783800.html
董建国: 啥原因
刘海峰: vm.overcommit_memory参数设置的原因,  = OVERCOMMIT_NEVER
董建国: 为啥要修改这个设置
焦兰兰: vm.overcommit_memory 表示内核在分配内存时候做检查的方式。这个变量可以取到0,1,2三个值。对取不同的值时的处理方式都定义在内核源码 mm/mmap.c 的 __vm_enough_memory 函数中。

取 1 的时候 ：
此时宏为 OVERCOMMIT_ALWAYS，函数直接 return 0，分配成功。

取 2 的时候： 
此时宏为 OVERCOMMIT_NEVER，内核计算：内存总量×vm.overcommit_ratio/100＋SWAP 的总量，如果申请空间超过此数值，则分配失败。vm.overcommit_ratio 的默认值为50。

取 0 的时候：
此时宏为 OVERCOMMIT_GUESS，内核计算：NR_FILE_PAGES 总量+SWAP总量+slab中可以释放的内存总量，如果申请空间超过此数值，则将此数值与空闲内存总量减掉 totalreserve_pages(?) 的总量相加。如果申请空间依然超过此数值，则分配失败。
焦兰兰: 申请的内存太大，vm.overcommit_memory＝2的话，就报错了
董建国: 我这边 这个值是 0
焦兰兰: 嗯，改成0，实例就启动成功了





## 产生core

ulimit -c unlimited
sudo bash -c 'echo "/home/uxdb/uxdbinstall/dbsql/bin/core-%e-%p-%t" > /proc/sys/kernel/core_pattern'
sudo bash -c 'echo "1" > /proc/sys/fs/suid_dumpable'