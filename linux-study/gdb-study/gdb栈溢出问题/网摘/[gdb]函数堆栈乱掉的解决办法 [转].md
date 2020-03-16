[gdb]函数堆栈乱掉的解决办法 [转]
zjfclimin关注
2017.04.12 17:37:41字数 2,578阅读 1,658
程序core掉,要去debug,但是函数堆栈乱掉了,很恶心.....经过Google/wiki一番,找到两种解决办法.
1. 手动还原backtrace
手动还原其实就是看栈里面的数据,自己还原函数栈,听起来很复杂其实也比较简单.手头上没有比较好的例子,所以大家就去看
http://devpit.org/wiki/x86ManualBacktrace 上面的例子.那个例子很好,是x86下面的,amd64下面也是类似.

x86ManualBacktrace

This tutorial will show you how to manually rebuild a backtrace with GDB on x86 using the stack frame pointer and current instruction pointer.
Consider the following gdb backtrace:
(gdb) bt
#0  0x0041d402 in ?? ()
#1  0x00aa930e in ?? () at ../nptl/sysdeps/unix/sysv/linux/i386/i686/../i486/lowlevellock.S:57 from /lib/tls/libc.so.6
#2  0x00afd820 in ?? () from /lib/tls/libc.so.6
#3  0x00afbff4 in ?? () from /lib/tls/libc.so.6
#4  0x00000028 in ?? ()
#5  0x00a3b9bf in ?? () from /lib/tls/libc.so.6
#6  0x00020460 in ?? ()
#7  0xb7801ba0 in ?? ()
#8  0xb78004e8 in ?? ()
#9  0x001a312b in _tr_init () from /usr/lib/libz.so.1
#10 0x001a1aa9 in deflateReset () from /usr/lib/libz.so.1
#11 0x00000000 in ?? ()
It's pretty clear that this is corrupted, evidence the following field:
#4 0x00000028 in ?? ()
Get the register information for the process:
(gdb) info reg
eax            0xfffffffc       -4
ecx            0x0      0
edx            0x2      2
ebx            0xafd820 11524128
esp            0xbf9ef304       0xbf9ef304
ebp            0xbf9ef358       0xbf9ef358
esi            0x0      0
edi            0xa85e980        176548224
eip            0x41d402 0x41d402
eflags         0x202    514
cs             0x73     115
ss             0x7b     123
ds             0x7b     123
es             0x7b     123
fs             0x0      0
gs             0x33     51
On x86:
%esp : top of the stack
%ebp : current stack frame
%eip : Instruction pointer
Stack Frame Layout for x86:
-----------------------------------
Low addresses
-----------------------------------
0(%esp)  | top of the stack frame (this is the same as -n(%ebp))
---------|-------------------------
-n(%ebp) | variable sized stack frame
-4(%ebp) | varied
0(%ebp)  | previous stack frame address
4(%ebp)  | return address
-----------------------------------
High addresses
Color Key:blue
Color Key:
blue : Current Stack frame address (%ebp)
 green: Higher stack frame addresses
 purple: Previous %ebp pointers held at by each stack frame (back chain pointer)
 red: Return address, i.e. calling function
Using the current stack frame address from %ebp dump the stack above it:
(gdb) info reg ebp
ebp            0xbf9ef358（blue）        0xbf9ef358
(gdb) x/2048h *0xbf9ef358(blue)
-------
0xbf9ef358(blue): 0xbf9ef388(purple)  0x00d94cf7(red)  0x0a85e988  0x00000024
0xbf9ef368: 0xbf9ef388  0x00d94d8a  0x00000000  0x05000000
0xbf9ef378: 0x00000000  0x0a85e994  0x00000000  0x0a86dacc
-------
0xbf9ef388(green): 0xbf9ef418(purple)   0x00c331ab(red)  0x0a85e994  0x00000015
0xbf9ef398: 0x00000000  0xb7800000  0x0992f188  0xbf9ef40c
...
0xbf9ef408: 0xbf9ef428  0x097150e0  0x0992f26c  0xbf9ef6e0
-------
0xbf9ef418: 0xbf9ef488  0x00dc7cb9  0x00000002  0x0a86dacc
0xbf9ef428: 0x00000000  0x00000000  0x00000001  0x00000016
0xbf9ef438: 0xbf9ef488  0x00dd7888  0x0a9f8e74  0xbf9ef6e0
0xbf9ef448: 0xce1cf0f4  0xbf9ef6e0  0x0992f26c  0x00000009
0xbf9ef458: 0xbf9ef488  0x00dcc28b  0x09718000  0x00004540
0xbf9ef468: 0x00000001  0xbf9ef6e8  0x0a8bb624  0x00000000
0xbf9ef478: 0x0992f26c  0xbf9ef6e4  0x09932570  0xbf9ef6e0
-------
0xbf9ef488: 0xbf9ef728  0x00dc76cd  0xbf9ef6e0  0xffffffff
0xbf9ef498: 0x0a1e8bf8  0x00000000  0x0a86e060  0x0a8b8428
...
0xbf9ef718: 0xbf9ef8f0  0x00000000  0xbf9ef7c0  0xbf9ef8f0
-------
0xbf9ef728: 0xbf9ef788  0x00dc78ba  0x09932570  0x00000000
0xbf9ef738: 0xbf9ef758  0x00da3a25  0xb780047c  0x0a7f1408
0xbf9ef748: 0x4373f45a  0x0a7f13fc  0x0aa2be2c  0xbf9ef8f0
0xbf9ef758: 0xbf9ef788  0x00dfbc5b  0x0a7f13fc  0x017f13fc
0xbf9ef768: 0x00000001  0x00000000  0x00000000  0xbf9efac0
0xbf9ef778: 0x09931fbc  0xbf9ef8f4  0x00000000  0xbf9ef8f0
-------
0xbf9ef788: 0xbf9ef938  0x00dc76cd  0xbf9ef8f0  0x00000000
0xbf9ef798: 0x00000000  0x00000000  0x0aa2bf10  0x0aaf9800
...
0xbf9ef928: 0xbf9ef9b0  0x00000000  0x00000000  0xbf9e6ad0
-------
0xbf9ef938: 0xbf9efa08  0x00da08f3  0x0a181c68  0x0aa47ef4
0xbf9ef948: 0x00000010  0xbf9ef9b8  0x00000000  0x00000000
...
0xbf9ef9f8: 0xbf9f0470  0xbf9efac8  0xbf9efac4  0x00000005
-------
0xbf9efa08: 0xbf9efa58  0x00da14ec  0xbf9efa20  0x00000000
0xbf9efa18: 0x00000000  0x00000000  0x00000024  0x09718000
0xbf9efa28: 0x09ebc944  0x00000000  0xbf9efac0  0x00000002
0xbf9efa38: 0xbf9efac8  0x00000000  0x00000001  0x00000000
0xbf9efa48: 0x00000000  0x00000000  0x00000000  0x00000000
-------
0xbf9efa58: 0xbf9efb28  0x00d7d5e0  0x09718000  0x00000000
0xbf9efa68: 0x09ebc944  0xbf9efac0  0x00000002  0xbf9efac8
...
0xbf9efb18: 0x00000000  0x00000001  0xbf9f0110  0xbf9effd0
-------
0xbf9efb28: 0xbf9efb48  0x00d7d713  0x00000001  0x00000000
0xbf9efb38: 0x00000000  0x00000000  0x00d6f7bc  0xbf9f0070
-------
0xbf9efb48: 0xbf9f01c8  0x00d6fb20  0x00000001  0x01031c20
0xbf9efb58: 0x0000009c  0xbf9f0110  0x00afbff4  0x0a117a64
...
-------
0xbf9f01c8: 0x00000000  0x00dfab20
NOTE: The previous memory dump has been converted to 'big endian' for the point of clarification.
   For brevity's sake unnecessary parts of the stack frames have been left out and replaced with "..."
Using this stack dump we know that the stack frame address in the %ebp register is the stack frame for the current instruction in the %eip register (unless this was a leaf function which didn't stack a frame but that's irrelevant for this discussion). Using the %ebp and %eip registers as a starting point we can build the first line in our backtrace rebuild:
StackFrame | Instruction
Pointer    | Pointer
------------------------
0xbf9ef358 | 0x0041d402
When program control branches to a new function a stack frame is stacked and the callee function's last address is stored at the new frame's address %ebp + 4 (i.e. the last memory address in the callee's stack frame which is +4 from the current stack frame at %ebp). In order to get the caller's stack frame and instruction pointer just look at %ebp and %ebp+4:
In the stack find the memory at the stack frame in %ebp and the one at %ebp+4 (which will hold the callee's instruction pointer).
0xbf9ef358: 0xbf9ef388  0x00d94cf7
So using the address at 0xbf9ef358 and 0xbf9ef35c which is 0xbf9ef388 and 0x00d94cf7 continue to build our list:
StackFrame | Instruction
Pointer    | Pointer
------------------------
0xbf9ef358 | 0x0041d402
0xbf9ef388 | 0x00d94cf7
Continue by looking at the next stack frame address 0xbf9ef388:
0xbf9ef388: 0xbf9ef418 0x00c331ab
Keep doing this until we have a full back trace. You'll know you've reached the bottom of the stack when the previous stack frame pointer is 0x00000000.
0xbf9f01c8: 0x00000000 0x00dfab20
Here's a complete manually rebuilt stack frame:
StackFrame | Instruction
Pointer    | Pointer
------------------------
0xbf9ef358 | 0x0041d402
0xbf9ef388 | 0x00d94cf7
0xbf9ef418 | 0x00c331ab
0xbf9ef488 | 0x00dc7cb9
0xbf9ef728 | 0x00dc76cd
0xbf9ef788 | 0x00dc78ba
0xbf9ef938 | 0x00dc76cd
0xbf9efa08 | 0x00da08f3
0xbf9efa58 | 0x00da14ec
0xbf9efb28 | 0x00d7d5e0
0xbf9efb48 | 0x00d7d713
0xbf9f01c8 | 0x00d6fb20
0x00000000 | 0x00dfab20

amd64下面,无非就是寄存器变成rbp,字长增加了一倍.当然这边选择了手动寻找函数返回地址,然后info symbol打印出函数名,其实还可以通过gdb格式化来直接打印函数名:
gdb>x/128ag　rbp内的内容
所以手动还原的办法就变得很简单:
gdb>info reg rbp　　　　　　　　　　　　*x86换成info reg ebp
gdb>x/128ag rbp内的内容　　　　　　　 *x86换成 x/128aw ebp的内容
这样就能看到函数栈.如果你想解析参数是啥,也是可以的,只是比较麻烦,苦力活儿....想解析参数,就要知道栈的布局,可以参考这篇文章:http://blog.csdn.net/liigo/archive/2006/12/23/1456938.aspx


函数调用栈比较有意思
作者：liigo
原文链接：http://blog.csdn.net/liigo/archive/2006/12/23/1456938.aspx
转载请注明出处：http://blog.csdn.net/liigo
昨天和海洋一块研究了下函数调用栈，顺便写两句。不足或错误之处请包涵！
理解调用栈最重要的两点是：栈的结构，EBP寄存器的作用。
首先要认识到这样两个事实：
1、一个函数调用动作可分解为：零到多个PUSH指令（用于参数入栈），一个CALL指令。CALL指令内部其实还暗含了一个将返回地址（即CALL指令下一条指令的地址）压栈的动作。
2、几乎所有本地编译器都会在每个函数体之前插入类似如下指令：PUSH EBP; MOV EBP ESP;
即，在程序执行到一个函数的真正函数体时，已经有以下数据顺序入栈：参数，返回地址，EBP。由此得到类似如下的栈结构（参数入栈顺序跟调用方式有关，这里以C语言默认的CDECL为例）：
+| (栈底方向，高位地址) |
 | .................... |
 | .................... |
 | 参数3                |
 | 参数2                |
 | 参数1                |
 | 返回地址             |
-| 上一层[EBP]          | <-------- [EBP]
“PUSH EBP”“MOV EBP ESP”这两条指令实在大有深意：首先将EBP入栈，然后将栈顶指针ESP赋值给EBP。“MOV EBP ESP”这条指令表面上看是用ESP把EBP原来的值覆盖了，其实不然——因为给EBP赋值之前，原EBP值已经被压栈（位于栈顶），而新的EBP又恰恰指向栈顶。
此时EBP寄存器就已经处于一个非常重要的地位，该寄存器中存储着栈中的一个地址（原EBP入栈后的栈顶），从该地址为基准，向上（栈底方向）能获取返回地址、参数值，向下（栈顶方向）能获取函数局部变量值，而该地址处又存储着上一层函数调用时的EBP值！
一般而言，ss:[ebp+4]处为返回地址，ss:[ebp+8]处为第一个参数值（最后一个入栈的参数值，此处假设其占用4字节内存），ss:[ebp-4]处为第一个局部变量，ss:[ebp]处为上一层EBP值。
由于EBP中的地址处总是“上一层函数调用时的EBP值”，而在每一层函数调用中，都能通过当时的EBP值“向上（栈底方向）能获取返回地址、参数值，向下（栈顶方向）能获取函数局部变量值”。如此形成递归，直至到达栈底。这就是函数调用栈。
编译器对EBP的使用实在太精妙了。
从当前EBP出发，逐层向上找到所有的EBP是非常容易的：
unsigned int _ebp;
__asm _ebp, ebp;
while (not stack bottom)
{
    //...
    _ebp = *(unsigned int*)_ebp;
}
如果要写一个简单的调试器的话，注意需在被调试进程（而非当前进程——调试器进程）中读取内存数据。

这个办法比较简单,很容易实践,但是有一个前提,如果栈的内容被冲刷干净了,你连毛都看不到(事实就是这样).所以你需要开始栈保护...至少你还能找到栈顶的函数...
gcc有参数: -fstack-protector 和 -fstack-protector-all,强烈建议开启....
2. 手动记录backtrace
开启了栈保护,这样至少会看到一个函数栈....如果想要知道更多的信息,对不起,没的...后来看公司内部的wiki,外加上google,得知很多人通过trace的办法来debug.:-D
简单的说,在gcc2时代,提供了两个接口函数:
void __cyg_profile_func_enter (void *this_fn, void *call_site)
void __cyg_profile_func_exit (void *this_fn, void *call_site)
方便大家伙做profile,然后很多人用这俩函数来调试代码.:-D
函数功能很简单,第一个就是函数入栈,第二就是函数出栈.所以你只要自己维护一个栈,然后在他入栈的时候你也入栈(只记录函数地址),出栈的时候你也出 栈.等程序挂了,你去看你自己维护的栈,这样就能搞到第二手的函数栈(第一手的可能被破坏了).然后在去info symbol或者x/num ag格式化打印也可以的.
需要注意的是,编译需要加上参数-finstrumnet-function,而且这里函数的声明需要加上attribute ((no_instrument_function))宏,否则他会无限递归调用下去,:-)
如果是单线程,就搞一个栈就行了,如果多个线程,一个线程一个栈~~~
参考:
http://devpit.org/wiki/x86ManualBacktrace
http://blogold.chinaunix.net/u3/111887/showart_2182373.html
http://blog.csdn.net/liigo/archive/2006/12/23/1456938.aspx
/**********************************************************************
• Make it Complex,and run away.
• From: http://www.cnblogs.com/egmkang/
• Email: egmkang [at] 163.com
• QQ Group: 20240291(慎入,可能没人打理)
**********************************************************************/
用打印方法调试
在客户项目那里混了半年，发现Top的客户确实是比我们牛逼。先说说调试的方法。
客户那边不依赖于GDB调试，因为他们可能觉得GDB依赖于系统 实现，不利于移植吧，所以客户的程序完全是依赖于打印调试的。这点很佩服他们的软件规划能力和项目管理，实现能力。说老实话，如果换了一家中国公司，每人 一个调试方法，要follow 一个rule是很不容易的。
完善的调试菜单。调试菜单并不难实现，只是一个打印和字符接受的函数。在其中控制是开放某些打印信息。
在每个模块中加上仔细规划打印输出，根据需求分成不同的基本。最好情况是在最高打印级别中可以可以发现所有的问题。打印级别可以很方便的动态控制。
函数调用LOG
如果能定位发生问题的模块，可以在该模块的在每个函数的调用入口加上打印一个函数名字+Enter，在返回处加上一个函数名字+Exit。对于每个模块用一个打印开关控制是否打印Trace信息。在调试菜单中控制这个打印开关。
如果懒得加打印语句，可以利用gcc 的-finstrument-functions 选项来快速的加入调试信息。-finstrumnet-function会是的编译器在函数调用的开始和退出处调用
void __cyg_profile_func_enter (void *this_fn, void *call_site)
void __cyg_profile_func_exit  (void *this_fn, void *call_site)。

可以利用这两个函数来跟踪函数调用的过程。
在 实现这两个函数时要加入attribute ((no_instrument_function));以避免编译器再调用这两个函数的时候也调用__cyg_profile_func_enter 和 __cyg_profile_func_exit 而造成循环调用。
可以用dladdr（）来获得this_fn的文件和函数名。code如下：
#define _GNU_SOURCE 
// 由于dladdr是GNU扩展，不是dl的标准函数，因此在这句话必须加在文件的开始处
#include 
#include 
void __cyg_profile_func_enter (void *this_fn, void *call_site) __attribute__ ((no_instrument_function));
void __cyg_profile_func_exit  (void *this_fn, void *call_site) __attribute__ ((no_instrument_function));
void __cyg_profile_func_enter (void *this_fn, void *call_site)
{
    Dl_info DLInfo;
    dladdr(this_fn, &DLInfo);
    printf("Enter file %s\n",DLInfo.dli_fname);
    printf("functio  %s\n",DLInfo.dli_sname);
    
}
void __cyg_profile_func_exit  (void *this_fn, void *call_site)
{
}
关于打印堆栈。可以用
        #include 
        void *array[10];
        char **strings;
        size_t size;
        size_t i;
        size = backtrace(array, 10); 
        strings = backtrace_symbols(array, size); 
        for(i=0;i        {
            printf ("%d, %p  ,%s\n",i,array[i],strings[i]);
        }
该方法需要编译器支持。
但是需要在编译的时候加上-rdynamic 否则只能输出在内存中的绝对地址。
在没有-rdynamic的时候，关于如何找到动态库的运行时地址还需要研究。
可以在系统运行的时候发送SIGSEGV给应用程序，产生当前进程的Coredump来获取动态库中函数的运行是地址。
用GDB获取backtrace的方法（在有-g选项的时候可以看到，不需要-rdynamic）:
list <*address>
在没有-g的时候，又该如何呢？

来自 <https://www.jianshu.com/p/86bf42cff7cf> 
