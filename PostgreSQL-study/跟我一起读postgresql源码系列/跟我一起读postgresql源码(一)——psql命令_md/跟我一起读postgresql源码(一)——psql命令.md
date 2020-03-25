# 跟我一起读postgresql源码(一)——psql命令

https://www.cnblogs.com/flying-tiger/p/6004314.html

进公司以来做的都是postgresql相关的东西，每次都是测试、修改边边角角的东西，这样感觉只能留在表面，不能深入了解这个开源数据库的精髓，遂想着看看postgresql的源码，以加深对数据库的理解，也算是好好提高自己。

但是目标很性感，现实很残酷，postgesql的源码都已经百万级了。单单.c文件都有1000+。怎么办，硬着头皮看吧，所幸postgrsql的源码很规范，这应该会给我省不少事。给自己顶一个小目标：每天看一点源码，每天都更新做不到，每周都更新吧，每周至少一篇。希望看到我的博客的朋友们也和我一起学习，我有什么理解不对的地方，也希望大家提出意见~

大部分人初次接触postgresql一般都是接触psql这个命令行工具吧，那么我们今天就从psql程序的源码开始看吧。

**对了，这里要说一下，我看的代码指的是postgresql9.5.4这个版本，不同版本的代码当然是有区别的~**

psql的源码分为两部分，一部分是psql的前台处理代码，代码都放在/src/bin/psql下；另一部分就是后台的查询处理过程的代码，代码较多，过程也较为复杂。这部分代码分布在/src/backend/目录下的许多子目录中。这篇博客是试水的文章，就先看看前台的代码吧。后台的代码放在后面的博客(如果有的话~)里再细细的说吧。

让我们先打开/src/bin/psql目录，这下面放的就是psql的前端程序代码。基本所有的程序都有个main函数，psql的main函数就放在startup.c里面。

我们先看两个数据结构：

```c
enum _actions
{
    ACT_NOTHING = 0,
    ACT_SINGLE_SLASH,
	ACT_LIST_DB,
	ACT_SINGLE_QUERY,
	ACT_FILE
};

struct adhoc_opts
{
	char	   *dbname;
	char	   *host;
	char	   *port;
	char	   *username;
	char	   *logfilename;
	enum _actions action;
	char	   *action_string;
	bool		no_readline;
	bool		no_psqlrc;
	bool		single_txn;
};
```

其中：

枚举类型**_actions**代表psql命令行程序当前所处的状态；

结构体adhoc_opts 储存了当前命令行程序的一些登录信息，比如登陆的数据库、主机、端口和日志文件的位置等等。

同样还有几个小函数：

```c
static void parse_psql_options(int argc, char *argv[],   //解析命令行选项
    			   struct adhoc_opts * options);         
static void process_psqlrc(char *argv0);                 //载入.psqlrc文件，如果存在的话
static void process_psqlrc_file(char *filename);         //被process_psqlrc()调用
static void showVersion(void);                           //格式化输出PostgreSQL的版本
static void EstablishVariableSpace(void);                //
```

对了，开头的两个宏定义指明了对psql命令行窗口的定制化信息：

```c
#ifndef WIN32
#define SYSPSQLRC    "psqlrc"
#define PSQLRC		".psqlrc"
#else
#define SYSPSQLRC	"psqlrc"
#define PSQLRC		"psqlrc.conf"
#endif
```

通过这两个文件可以定制自己的命令行窗口(分别指linux和windows下)的信息显示式样，很方便实用。

不废话，进main函数。
第一个if显示的很显然是psql的help和version命令。

在后面有一个变量很重要：pset。它的数据结构PsqlSettings的定义放在src/bin/psql/settings.h里面。这个数据结构主要要表达的是当前psql命令行属性和状态集，通过这些属性和状态集判断和处理来控制程序的走向。

```c
typedef struct _psqlSettings
{
    PGconn	   *db;				/* connection to backend */
	int			encoding;		/* client_encoding */
	FILE	   *queryFout;		/* where to send the query results */
	bool		queryFoutPipe;	/* queryFout is from a popen() */
	FILE	   *copyStream;		/* Stream to read/write for \copy command */
	printQueryOpt popt;
	char	   *gfname;			/* one-shot file output argument for \g */
	char	   *gset_prefix;	/* one-shot prefix argument for \gset */
	bool		notty;			/* stdin or stdout is not a tty (as determined on startup) */							 
	enum trivalue getPassword;	/* prompt the user for a username and password */
	FILE	   *cur_cmd_source; /* describe the status of the current main  loop */								
	bool		cur_cmd_interactive;
	int			sversion;		/* backend server version */
	const char *progname;		/* in case you renamed psql */
	char	   *inputfile;		/* file being currently processed, if any */
	uint64		lineno;			/* also for error reporting */
	uint64		stmt_lineno;	/* line number inside the current statement */
	bool		timing;			/* enable timing of all queries */
	FILE	   *logfile;		/* session log file handle */
	VariableSpace vars;			/* "shell variable" repository */

	/*
	 * The remaining fields are set by assign hooks associated with entries in
	 * "vars".  They should not be set directly except by those hook
	 * functions.
	 */
	bool		autocommit;
	bool		on_error_stop;
	bool		quiet;
	bool		singleline;
	bool		singlestep;
	int			fetch_count;
	PSQL_ECHO	echo;
	PSQL_ECHO_HIDDEN echo_hidden;
	PSQL_ERROR_ROLLBACK on_error_rollback;
	PSQL_COMP_CASE comp_case;
	HistControl histcontrol;
	const char *prompt1;
	const char *prompt2;
	const char *prompt3;
	PGVerbosity verbosity;		/* current error verbosity level */
} PsqlSettings;
```

main主要干了哪些事儿呢？：比如你输入：

```sh
psql -U postgres -p 26500 -w 
```

程序在读取psql后面这一大串参数之前，先初始化一些环境变量，当确定不是--version和--help这种输出帮助信息就结束的参数时，利用输入的参数，初始化前面提到的_psqlSettings类型的变量pset。然后验证登录密码(如果指定了的话)，

进入334行的MainLoop函数。这个函数的定义在统计文件夹的mainloop.c文件中。这个函数的主要成分就是一个大的循环：

循环读取命令行的查询请求-->将请求发往后端-->从后端获取请求的结果。

值得一说的是，MainLoop维护PQExpBuffer类型的query_buf，previous_buf，history_buf三个buffer。这三个buffer的定义在src/interfaces/libpq/pqexpbuffer.h。定义如下：

```c
typedef struct PQExpBufferData
{
    char	   *data;
	size_t		len;
	size_t		maxlen;
} PQExpBufferData;

typedef PQExpBufferData *PQExpBuffer;
```

其中history_buf保存的是以前的历史操作。previous_buf 保存的当前操作，由于psql中每个命令可以有多行（通过”\”+”Enter”进行分割），所以previous_buf 会一行一行的添加进char* line中的输入，当一个命令满足发出条件时，再把previous_buf中的数据送到query_buf中去。

在获取到sql命令后，首先使用函数psql_scan_setup对启动对指定行的词法分析。然后调用psql_scan函数返回语句的状态。返回的状态有下面几种：

```c
PSCAN_SEMICOLON     以分号结束的命令
PSCAN_BACKSLASH     以反斜杆结束的命令
PSCAN_INCOMPLETE    到达行尾并没有完成的命令
PSCAN_EOL           遇到了EOL结束符
```

MainLoop函数就是根据返回值控制Buffer，当一个命令输入完毕以后发送到后台去执行。

在完成词法分析后，调用SendQuery(const char *query)函数执行命令，该函数处理没有连接数据库、事务处理等具体细节。再调用results = PQexec(pset.db, query)，获取数据库后台返回的结果。在命令执行以后，使用ProcessCopyResult(results)把运行结果显示在屏幕上。

如果后台完成查询任务，会通知前端它已经空闲，这时前端可以发送新的查询命令。下面给出了backend返回给前端的数据结构，前端按照该结构显示结果。值得说一句的是，虽然对于psql交互窗口显示出的结果可以完全看作是一串字符串,并不需要区分出表中结果每一个域。但psql和backend的通信协议是所有前台(包括基于GUI界面)和后台的通信协议。只不过psql显示时把它转换成字符串的表现形式。

```c
struct pg_result
{
    int			ntups;
	int			numAttributes;
	PGresAttDesc *attDescs;
	PGresAttValue **tuples;		/* each PGresTuple is an array of
								 * PGresAttValue's */
	int			tupArrSize;		/* allocated size of tuples array */
	int			numParameters;
	PGresParamDesc *paramDescs;
	ExecStatusType resultStatus;
	char		cmdStatus[CMDSTATUS_LEN];		/* cmd status from the query */
	int			binary;			/* binary tuple values if binary == 1,
								 * otherwise text */
	/*
	 * These fields are copied from the originating PGconn, so that operations
	 * on the PGresult don't have to reference the PGconn.
	 */
	PGNoticeHooks noticeHooks;
	PGEvent    *events;
	int			nEvents;
	int			client_encoding;	/* encoding id */
	/*
	 * Error information (all NULL if not an error result).  errMsg is the
	 * "overall" error message returned by PQresultErrorMessage.  If we have
	 * per-field info then it is stored in a linked list.
	 */
	char	   *errMsg;			/* error message, or NULL if no error */
	PGMessageField *errFields;	/* message broken into fields */
	/* All NULL attributes in the query result point to this null string */
	char		null_field[1];
	/*
	 * Space management information.  Note that attDescs and error stuff, if
	 * not null, point into allocated blocks.  But tuples points to a
	 * separately malloc'd block, so that we can realloc it.
	 */
	PGresult_data *curBlock;	/* most recently allocated block */
	int			curOffset;		/* start offset of free space in block */
	int			spaceLeft;		/* number of free bytes remaining in block */
};
```

该数据结构定义在src/interfaces/libpq/libpq-int.h中。

总之呢，前台就是这个样子，和后台的查询处理的逻辑相比要简单得多。

第一次写对源码解析的东西，思路比较乱，写的也比较杂乱无章，基本是想到哪写到哪。看来以后还得进一步加强写作的锻炼。这次感觉好像源码贴的有点多，下次尽量注意哈。这次就先这样了，不管怎么说总算开了个头，明天早起在修改修改吧。

希望自己能坚持下去。

作者：非我在
出处：http://www.cnblogs.com/flying-tiger/
本文版权归作者和博客园共有，欢迎转载，但未经作者同意必须保留此段声明，且在文章页面明显位置给出原文连接，否则保留追究法律责任的权利.
感谢您的阅读。如果觉得有用的就请各位大神高抬贵手“推荐一下”吧！你的精神支持是博主强大的写作动力。
如果觉得我的博客有意思，欢迎点击首页左上角的“+加关注”按钮关注我！

评论列表
   回复 引用#1楼 2016-11-01 15:23 Anonymous Coward
大部分人应该接触的是pgAdmin
支持(0) 反对(0)
   回复 引用#2楼 [楼主] 2016-11-01 15:36 非我在
@ Anonymous Coward
那个也只是个集成的图形界面，它调用的还是psql，pg_dump等等这些命令。
支持(0) 反对(0)
   回复 引用#3楼 2016-11-01 15:50 Anonymous Coward
@ 非我在
这个执行文件有10M，静态导入库不多嘛
其中也用到了LIBPQ.dll，是不是还需要以RPC方式调用呢
支持(0) 反对(0)
   回复 引用#4楼 [楼主] 2016-11-01 16:27 非我在
@ Anonymous Coward
我看在/src/interfaces/libpq 下有相关的文件；而且在linux下我的postgresql安装目录下的/lib下有libpq.so和libpq.a这些动态和静态库，应该是调用的这里的？我下班再细细看看哈
支持(0) 反对(0)
   回复 引用#5楼 2016-11-02 12:32 寻风问雨
加油，纯应用的飞过

