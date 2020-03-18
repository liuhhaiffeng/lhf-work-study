
多个选项过滤有如下2种方法:
cat xx.txt|grep -E "abc|efg"
cat xx.txt|grep -e "abc" -e "efg"
