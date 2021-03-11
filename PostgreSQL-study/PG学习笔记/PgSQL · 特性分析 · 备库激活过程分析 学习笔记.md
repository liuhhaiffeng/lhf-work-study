# PgSQL · 特性分析 · 备库激活过程分析 学习笔记

by 刘海峰 2021.1.22

http://mysql.taobao.org/monthly/2015/12/05/



PostgreSQL支持快速激活（fast promote）和非快速激活(fallback promote)：

1. **fast promote** 开启数据库读写前，不需要做检查点。而是推到开启读写之后执行一个CHECKPOINT_FORCE检查点。
2. **fallback_promote** 在开启数据库读写前，需要先做一个检查点，现在这个模式已经不对用户开放，需要修改代码，只是用作调试。

通过pg_ctl命令行工具，向postmaster发SIGUSR1信号，通知它激活数据库。 首先会写一个promote文件，告诉postmaster，是fast_promote。

数据恢复时，检查standby是否收到promote请求或是否存在trigger文件。 如果是promote请求，则检查有没有promote文件，或者fallback_promote文件，如果有promote文件，则是fast_promote请求。如果有fallback_promote文件，则不是fast_promote请求（实际上根本不可能检测到fallback_promote文件，因为没有写这个文件的操作）。所以通过pg_ctl promote来激活，一定是fast promote的，即不需要先做检查点再激活。 如果检查到trigger文件，同样也是fast promote激活模式。