# PostgreSQL中使用pstack打印fork子进程所有线程堆栈信息

PostgreSQL数据库在并行查询中, 出现如下"stack depth limit exceeded"的错误, 因此想使用pstack来打印其堆栈信息, 依次来排查错误.

```c
void
check_stack_depth(void)
{
	if (stack_is_too_deep())
	{
		ereport(ERROR,
				(errcode(ERRCODE_STATEMENT_TOO_COMPLEX),
				 errmsg("stack depth limit exceeded"),
				 errhint("Increase the configuration parameter \"max_stack_depth\" (currently %dkB), "
						 "after ensuring the platform's stack depth limit is adequate.",
						 max_stack_depth)));
	}
}
```

使用pstack pid 打印进程堆栈信息, 有2种方式, 一是在进程中 "pstack pid"来打印, 二是 "sudo  pstack  pid" 在外部打印, 外部打印需要sudo权限.

## 进程外部打印

下面select.sh脚本是想打印select count(*) 时, fork出来的并行查询子进程(即: bgworker parallel )的堆栈信息, 构造了下面的脚本可以进行抓取.

```sql
create table t1(id int, info text);
```

select.sh 
```sh

# 1. 要触发并行查询, 首先要确保t1中的数据量足够的多, 如: 1千万条, 否则不会触发并行查询
# 2. 并行查询的开关要打开
# 3. 至少要2个客户端同时查询
# 下面在select.sh 脚本中, 通过2条select count(*)的后台执行, 来模拟客户端的并行查询
./psql -p 5432 -c "select count(*) from t1;" &
echo "main wait 5432 1"

./psql -p 5432 -c "select count(*) from t1" &
echo "main wait 5432 2"

# 抓取并行子进程堆栈信息构造方法如下
# 这里需要等待一点时间, 因为前面的select查询时异步执行的, 如果不等待,
# 执行到下面 ps -ef 获取其进程pid时, 并行查询子进程可能还没fork出来,
# list的结果会为空
sleep 0.1

# 打印出所有并行查询子进程, 存放在list中
ps -ef|grep -v color|grep para
list=`ps -ef|grep -v grep|grep para|awk '{print $2}'`
echo "list is " $list

# 启动一个循环, 逐次打印各个进程的堆栈信息
# 在具体实践中, 这里有2个注意事项
# 1 因为是sudo运行, 所以在执行select.sh时, 需要输入root密码, 
#   虽然多次循环, 但实际只需要输入一次root密码就够了, 我是在centos
#  下, centos中, sudo 输入一次root密码, 后续短时间内如果再次sudo, 
#   默认是不需要root密码的
#
#  这里输入密码的速度要快, 否则 并行子进程可能会很快执行完并结束掉, 
#  pstack 来不及打印
#
#  个人解决方法: 使用xshell, 在xshell中将输入root密码的操作添加到"
#  快速命令集"中, 然后关联一个"Ctrl+F1"之类的快捷键, select.sh执行
#  时, 按下"Ctrl+F1"即可快速输入密码.
#
# 这样就可以打印出其进程堆栈信息了

for pid in $list
do
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> pid = " $pid
  sudo pstack $pid
done

wait
```

## 进程内部打印

在进程内部打印, 即在程序代码中调用 "pstack getpid()", 这种方式不需要sudo执行.

```c
#include <sys/types.h>
#include <unistd.h>

bool
stack_is_too_deep(void)
{
	char		stack_top_loc;
	long		stack_depth;

	/*
	 * Compute distance from reference point to my local variables
	 */
	stack_depth = (long) (stack_base_ptr - &stack_top_loc);

	/*
	 * Take abs value, since stacks grow up on some machines, down on others
	 */
	if (stack_depth < 0)
		stack_depth = -stack_depth;

	/*
	 * Trouble?
	 *
	 * The test on stack_base_ptr prevents us from erroring out if called
	 * during process setup or in a non-backend process.  Logically it should
	 * be done first, but putting it here avoids wasting cycles during normal
	 * cases.
	 */
	if (stack_depth > max_stack_depth_bytes &&
		stack_base_ptr != NULL)
        {
            char str[128] = {0};
            sprintf(str, "pstack %d", getpid());
            system(str);

            return true;
        }

}
```

**备注** 在上述进程内, system(str)有时候在log中的输出为空, 不知何故??? 

可能原因:
1) bgworker pallell 子进程运行时间太短, 来不及打印
2) system(str)的输出没有定向到log中
