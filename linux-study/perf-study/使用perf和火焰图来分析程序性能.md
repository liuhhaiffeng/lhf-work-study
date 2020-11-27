# 使用perf和火焰图来分析程序性能

2、使用火焰图展示结果

1、Flame Graph项目位于GitHub上：https://github.com/brendangregg/FlameGraph

2、可以用git将其clone下来：git clone https://github.com/brendangregg/FlameGraph.git

 

我们以perf为例，看一下flamegraph的使用方法：

1、第一步

$ sudo perf record -e cpu-clock -g -p 28591

-g 选项是告诉perf record额外记录函数的调用关系

-e cpu-clock 指perf record监控的指标为cpu周期

-p 指定需要record的进程pid

程序运行完一段时间后, Ctrl+c结束执行后, perf record会生成一个名为perf.data的采样数据文件，如果之前已有，那么之前的perf.data文件会被覆盖

获得这个perf.data文件之后，就需要perf report工具进行查看.

2、第二步

用perf script工具对perf.data进行解析

sudo perf script -i perf.data &> perf.unfold

注意: 上述命令需要在 root 权限下运行, 否则生存的 perf.unfold 是不正确的 (例如: 文件体积很小)

3、第三步

将perf.unfold中的符号进行折叠：

#./stackcollapse-perf.pl perf.unfold &> perf.folded

或

sudo ./stackcollapse-perf.pl perf.unfold &> perf.folded



4、最后生成svg图：

sudo ./flamegraph.pl perf.folded > perf.svg



## 注意

上述第一步, 采集的数据时间越长, 生成的"火焰图"越好.

[如何读懂火焰图？](https://ruanyifeng.com/blog/2017/09/flame-graph.html)



[如何读懂火焰图？](https://www.cnblogs.com/tcicy/p/8491899.html)

Off-CPU 火焰图



Linux火焰图性能分析

https://zhuanlan.zhihu.com/p/85654612


## 参考

[Linux Perf 性能分析工具及火焰图浅析](https://zhuanlan.zhihu.com/p/54276509)

[perf + 火焰图分析程序性能](https://www.cnblogs.com/happyliu/p/6142929.html)