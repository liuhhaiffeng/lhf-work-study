判断指定pid号的进程是否存在

https://blog.csdn.net/g_super_mouse/article/details/109732535

编程小耗子 2020-11-16 23:15:05  162  收藏
分类专栏： c/c++ 文章标签： c语言 linux
版权
判断指定进程是否存在
// 存在返回1
int process_exist(char *pid)
{
	int ret = 0;
	char pid_path[64] = {0};
	struct stat stat_buf;
	if(!pid)
		return 0;
	snprintf(pid_path, 64, "/proc/%s/status", pid);
	if (stat(pid_path, &stat_buf) == 0)
		ret = 1;
	return ret;
}



————————————————
版权声明：本文为CSDN博主「编程小耗子」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/g_super_mouse/article/details/109732535