## C++错误解决：double free or corruption (out): 0x00000000011abe70 ***

### 前言
博主最近疯狂的迷恋上了leetcode刷题，想要锻炼脑力和算法思想的，推荐去这个网站上刷题。因为是用c++编写的，而且提交的时候会经常遇到一些报错。比如题目的这个。好了，下面开始解答。


### 错误信息
double free or corruption (out): 0x00000000011abe70 ***

### 问题分析
基本上根据题目判定，类型没得跑，内存问题。

所以会有几种情况：

1.    内存重复释放，看程序中是否释放了两次空间（一般不会是这种情况，毕竟。。太明显）

2.    内存越界。（大部分是这种情况，如果你使用了数组，或者开辟了空间，但是在循环的时候越界了，就会出现这种情况）

### 问题解决

```c
public:
    int removeDuplicatesPlus(vector<int>& nums) {
        if(nums.size() == 0){
            return 0;
        }
//        TODO,, 对数组进行插入排序
//插入排序
        for(int i=1 ; i<= nums.size(); i++){
            int tmp = nums[i];
            int j;
            for(j=i; j>0 && nums[j-1] > tmp; j--){
                nums[j] = nums[j-1];
            }
            nums[j] = tmp;
        }
 
        for(int i=0 ;i<nums.size(); i++){
            printf("v[%d] ==> %d\n", i, nums[i]);
        }
 
 
 
//        TODO.. 对重复的元素进行去重且限定个数<=2
//        计数器
        int count = 1;
//        排序游标
        int k = 0;
        for(int i=1; i<nums.size(); i++){
            
//            TODO.. ==k的时候，++count,且如果count>2时候 i++,k不动。count<=2时候k++,i++，并交换
//            TODO.. 不等于的k的时候 ++k 与 i位置进行交换
            if(nums[i] == nums[k] && ++count<=2){
                k++;
                if( k != i){
                    swap(nums[k], nums[i]);
                }
            } else if(nums[i] != nums[k]){
                count = 1;
                if(i != k){
                    swap(nums[i], nums[++k]);
                }
            }
        }
        return k+1;
    }
};
```

PS：leetcode上序号80的问题，有兴趣的小伙伴可以去看一下问题，尝试解决一下。

根据自己的程序情况，可能是数组问题，排查遍历数组的for循环，发现是插入排序的时候

```c
for(int i=1 ; i<= nums.size(); i++){
    int tmp = nums[i];
    int j;
    for(j=i; j>0 && nums[j-1] > tmp; j--){
        nums[j] = nums[j-1];
    }
    nums[j] = tmp;
}
```

第一个for循环数组越界，导致内存问题。更改成

```c
for(int i=1 ; i< nums.size(); i++)
```

问题解决
————————————————
版权声明：本文为CSDN博主「桥路丶」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/qq_33876553/article/details/79609321