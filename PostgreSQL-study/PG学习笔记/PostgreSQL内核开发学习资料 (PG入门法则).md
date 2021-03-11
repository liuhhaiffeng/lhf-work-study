## [*PostgreSQL*内核开发学习资料 (PG入门法则)](https://zhuanlan.zhihu.com/p/98021328)

[![王硕](https://pic1.zhimg.com/50/v2-9c43dee093d9a5db0899b46b1c04c84d_s.jpg?source=4e949a73)](https://www.zhihu.com/people/wang-shuo-73-30-40)

[王硕](https://www.zhihu.com/people/wang-shuo-73-30-40)[](https://www.zhihu.com/question/48510028)

阿里巴巴 技术专家

我自2011年便开始进行PostgreSQL内核开发岗，在公司内也算是时间比较久了，带了一些新人入门，总结了一些不同阶段需要学习的资料。

我将PostgreSQL内核知识划分为3层：

1. 数据库基础对象，内容最多，比如系统表、表、系统函数、语法、前端工具、通讯协议等等；
2. 进程运行过程；
3. 数据库核心内容，存储、事务以及查询处理器。

根据内核知识层级，我将PostgreSQL内核开发工程师的知识水平划分为5个级别，由于代码、逻辑耦合度较高，所以无法完全依照知识层级划分，我采取了以点到面的逻辑划分：

1. 对数据库架构有一个基本认识。熟悉数据库基础对象，并能根据数据库基础对象延伸至进程模型，了解进程工作流程。比如熟悉语法后，增加新的语法以及功能，比如开启和关闭约束；
2. 根据已知的数据库对象、进程运行过程内容横向扩展，了解不同基础对象以及进程工作内容，然后向核心内容拓展，然后再以核心内容对已有知识整合，比如了解WAL结构后，延伸至流复制、逻辑复制、PITR等。对数据库有一个全面、深入的认识。
3. 对数据库有深入的研究，能够对数据库功能进行创新。对于背后的理论、原理有清晰的认识。能够对数据库架构进行修改、优化。比如JIT。能够根据一些先进理论对数据库进行改造。比如AI智能优化[[1\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_1)。
4. 能够对数据库架构做出具有开创性的改变，比如分布式。产品例如，Google的Spanner，Pivotal的Greenplum。
5. 对数据库的基础理论进行提出、修改，比如新的数据模型。当前学术界对于新的数据模型已经有了大量的讨论，比如对象关系型数据库[[2\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_2)，比如对象代理模型[[3\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_3)。

下面列举了一些各个阶段，我认为应该学习到的资料：

1. 第一阶段：

2. 1. 数据库使用、认识：

   2. 1. 官方文档1，2章[[4\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_4)
      2. 斯坦福的数据库课程[[5\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_5)，[ARCHIVED Introduction to Databases](https://link.zhihu.com/?target=http%3A//infolab.stanford.edu/db_pages/classes.html)。
      3. 《数据库系统教程》[[6\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_6)

   3. 内核知识：

   4. 1. 《PostgreSQL内核分析》[[7\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_7)，完成阅读，基于8.4介绍的，很好的内核阅读材料。
      2. PostgreSQL代码注释，Readme。
      3. Bruce[[8\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_8)的博客：[https://momjian.us/main/presentations/extended.html](https://link.zhihu.com/?target=https%3A//momjian.us/main/presentations/extended.html)
      4. 社区博客[[9\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_9)：[https://planet.postgresql.org/](https://link.zhihu.com/?target=https%3A//planet.postgresql.org/)

3. 第二阶段：

4. 1. 数据库使用：

   2. 1. 官方文档3，4章[[4\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_4)

      2. 德哥[[10\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_10)培训资料（内容相对较多）：[https://github.com/digoal/blog/blob/master/201901/20190105_01.md](https://link.zhihu.com/?target=https%3A//github.com/digoal/blog/blob/master/201901/20190105_01.md)

      3. 资料补充（建议观看德哥培训视频以及选择以下四本书一本观看即可，有时间在进行查漏补缺）：

      4. 1. 《由浅入深PostgreSQL》[[11\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_11)
         2. 《[PostgreSQL实战](https://link.zhihu.com/?target=https%3A//item.jd.com/12405774.html)》[[12\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_12)
         3. 《PostgreSQL修炼之道：从小工到专家》[[13\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_13)
         4. 《PostgreSQL 9X之巅》[[14\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_14)

   3. 内核内容：

   4. 1. [interdb](https://link.zhihu.com/?target=http%3A//www.interdb.jp/pg/)，日本人的PostgreSQL架构。
      2. 社区patch列表[[15\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_15)：[https://commitfest.postgresql.org/](https://link.zhihu.com/?target=https%3A//commitfest.postgresql.org/)
      3. 社区邮件列表[[16\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_16)：[https://www.postgresql.org/list/pgsql-hackers/](https://link.zhihu.com/?target=https%3A//www.postgresql.org/list/pgsql-hackers/)
      4. 《Debug Hacks》
      5. 《Linux程序设计》
      6. 之前提到的博客。

5. 第三阶段（当前阶段没有单纯数据库使用了，而是更多以内核为研究对象）：

6. 1. 《大型共享数据库的数据关系模型》[[17\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_17)
   2. 《Architecture of a Database System》[[18\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_18)
   3. 《数据库系统实现》[[19\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_19)
   4. 《PostgreSQL查询引擎源码技术探析》
   5. 《数据库查询优化器的艺术》[[20\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_20)
   6. 《数据库事务的艺术》[[20\]](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_20)
   7. PostgreSQL注释中提到的论文。
   8. 《深入理解计算机系统》
   9. 《支撑处理器的技术》
   10. 《编译原理》
   11. 《算法导论》
   12. 未完待续……

7. 第四阶段：

8. 1. Spanner论文
   2. Raft论文
   3. ……

9. 第五阶段：

10. 1. 未知……

有什么建议，也欢迎大家补充，谢谢。

## 参考

1. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_1_0)本人正处于2级未满，学习3级内容中。关于4级、5级仅仅是我对于未来的构想，说不上成熟。
2. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_2_0)Michael Ralph Stonebraker提出了对象关系型数据库，PostgreSQL正是这样的数据库。其中对象我的理解为表现在表继承。
3. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_3_0)彭智勇教授正在研究的课题。结合对象概念和关系型，提出新的数据库理论模型，已经受到国际认可。
4. ^[a](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_4_0)[b](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_4_1)官方文档，有能力的同学请阅读英文原版 https://www.postgresql.org/docs/12/index.html
5. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_5_0)讲述基本的数据库知识，类似于《数据库概述》课程
6. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_6_0)斯坦福大学数据库课程第一学期教科书
7. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_7_0)彭智勇、彭煜玮著。我的第一本内核书。
8. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_8_0)PostgreSQL社区大佬，核心组成员
9. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_9_0)社区开放的博客平台
10. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_10_0)德哥，原名周正中，PostgreSQL大牛
11. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_11_0)彭煜玮教授新作。
12. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_12_0)作者谭峰、张文升，具有多年PG从事经验
13. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_13_0)作者唐成，具有多年数据库从事经验
14. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_14_0)本人参与翻译，作者是我的好朋友Ibrar
15. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_15_0)开发者提交patch后的邮件列表，这里会讨论需求、设计、问题等等
16. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_16_0)内容比patch列表要多，有一部分仅仅是讨论，但未提交到commitfest内的。
17. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_17_0)《A Relational Model of Data for Large Shared Data Banks》，E. F. CODD在1970年所著，阐述了关系型的定义，是关系型数据库之父、奠基人。
18. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_18_0)Michael Ralph Stonebraker的论文
19. [^](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_19_0)斯坦福大学数据库第二学期课程教材
20. ^[a](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_20_0)[b](https://www.zhihu.com/search?type=content&q=PostgreSQL 实现undo功能#ref_20_1)李海翔著，对于数据库有深入研究

[编辑于 2020-07-28](https://zhuanlan.zhihu.com/p/98021328)

赞同 1009 条评论收藏

分享

 举报