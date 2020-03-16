
sudo gdb --tui attach 6680
sudo gdb --tui -p 6680

注意: 使用图形调试时, 在下面的命令输入窗口中, 如果想要回翻上一条命令, 
像非图形化调试时, 使用"上箭头"了, 就会滚动上面的"图形化窗口的代码行",
这时需要使用"ctrl+p"来达到目的.

## 参考

[GDB tui使用方法](https://blog.csdn.net/weixin_34150503/article/details/91681008)