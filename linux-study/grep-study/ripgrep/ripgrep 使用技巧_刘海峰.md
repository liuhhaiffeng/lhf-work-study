# ripgrep 使用技巧

## 查看帮助

rg --help

## 常用的查找

在之前目录下递归查找PostmasterMain (相比于grep -r 或grep -R,  少写一个参数, 更加方便)
默认大小写敏感, 不保证完整匹配
rg  PostmasterMain    

大小不敏感, 不保证完整匹配
rg -i PostmasterMain

大小写敏感, 保证完整匹配
rg -w PostmasterMain

大小写不敏感, 保证完整匹配
rg -iw PostmasterMain

特定查找(-t后面直接跟文件扩展名, 如果有多个特定项, 则多次 -t)
rg -tc -th PostmasterMain               # 仅搜索 *.c, *.h文件
rg -tc -th -thtml PostmasterMain        # 仅搜索 *.c, *.h. *.html文件

rg -w -tc -th PostmasterMain               # 仅搜索 *.c, *.h文件, 并且保证完整匹配

排除查找(-T后面直接跟文件扩展名, 如果有多个排除项, 则多次 -T)
注意和特定查找的区别, 前者是-t, 后者是-T
rg -Thtml -Ttxt PostmasterMain         # 过滤 *.html 和 *.txt文件的查找

rg也支持正则表达式搜索, 用法和grep一样, 如果涉及了正则表达式, 那么要查找的pattern必须要用双引号(" ")和单引号(' ')包起来

rg "PostmasterMain\(" 或 rg 'PostmasterMain\('
rg "\bPostmasterMain\(" 或 rg '\bPostmasterMain\('

等价的grep -r实现
grep -rE "\\bPostmasterMain\("

正则表达式也可以搭配 -w -i, -t, -T等选项参数
rg -w "PostmasterMain"

### 函数名称模式搜索

在所有的*.c文件中, 查找包含 bg  worker  的函数名称
rg -tc ".*bg.*worker.*\("

如果安装了gnu global, 会更加的准确, global -c 会打印出所有的函数名称, 然后再使用grep 自由过滤
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

## 与grep的比较

rg的结果

```
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ rg -tc "WSAStartup failed:"
src/backend/main/main.c
316:			write_stderr("%s: WSAStartup failed: %d\n",

src/bin/ux_dump/parallel.c
265:			fprintf(stderr, _("%s: WSAStartup failed: %d\n"), progname, err);
```

grep -r 的结果

```
[uxdb@192 ~/uxdb-ng-rac/uxdb-2.0]$ grep -nr --include="*.c" "WSAStartup failed:"
src/backend/main/main.c:316:			write_stderr("%s: WSAStartup failed: %d\n",
src/bin/ux_dump/parallel.c:265:	
```

rg -tc "WSAStartup failed:"
grep -nr --include="*.c" "WSAStartup failed:"

可以看出, rg的输入更加简洁一些

## 快速打开目标所在文件并跳转到目标行

如上述查找结果如下:

```
src/backend/main/main.c
316:			write_stderr("%s: WSAStartup failed: %d\n",
```

使用 
1) vim  文件路径  +/line
或
2) vim  文件路径 +/pattern

vim  src/backend/main/main.c +316
vim src/backend/main/main.c +/"WSAStartup failed"

## 最大优势

万众期待的 ripgrep 来了。
`grep` 是咱们 Linuxer 几乎每天都会用到的行搜索工具，几乎所有发行版都自带有这个工具。多少年来，没有什么改变，如一潭死水。`ripgrep`的出现，给这个领域带来了一场轰动。
ripgrep 很牛，现在其 github 已经接近 14000 stars 了。仓库地址是：https://github.com/BurntSushi/ripgrep。
ripgrep 超越 grep 的第一点就是 ripgrep 是跨平台的，不再歧视 Windows 用户，Windows， Linux，macOS 效果完全一致。