Putty本无树，MinGW亦非台
如何调整vs code选择补全的快捷键?

[如何调整vs code选择补全的快捷键?---韦易笑答案](https://www.zhihu.com/question/62743695/answer/1054302289)

[如何调整vs code选择补全的快捷键?](https://www.zhihu.com/question/62743695/answer/1054302289)

56 人也赞同了该回答
Keyboard shortcuts:

[
    {
        "key": "tab",
        "command": "acceptSelectedSuggestion",
        "when": "suggestWidgetVisible && textInputFocus"
    },
    {
        "key": "shift+tab",
        "command": "acceptSelectedSuggestion",
        "when": "suggestWidgetVisible && textInputFocus"
    },
    {
        "key": "tab",
        "command": "selectNextSuggestion",
        "when": "editorTextFocus && suggestWidgetMultipleSuggestions && suggestWidgetVisible"
    },
        {
        "key": "shift+tab",
        "command": "selectPrevSuggestion",
        "when": "editorTextFocus && suggestWidgetMultipleSuggestions && suggestWidgetVisible"
    }
]
设置好了以后就可用 TAB，SHIFT+TAB 循环选择而不需要用方向键了，接受的话按回车。

发布于 2020-03-04
​赞同 56​
​收起评论
​分享
​收藏
​喜欢
​
收起​
7 条评论
​切换为时间排序
约翰·法雷尔
约翰·法雷尔11 天前
学到了，vscode 还可以这么配置

​赞
​回复
​踩
​举报
雾色
雾色11 天前
你也用vscode啊[微笑]，还以为一直在用vim
​赞
​回复
​踩
​举报
韦易笑
韦易笑 (作者) 回复雾色11 天前
我用一切编辑器，并学习他们的长处，然后将带回 vim。

​1
​回复
​踩
​举报
韦易笑
韦易笑 (作者) 回复雾色11 天前
这个 vscode 的 tab 轮询补全，是 vim 下面的经验带过来而已。

​1
​回复
​踩
​举报
展开其他 1 条回复
李健健
李健健10 天前
好像acceptSelectedSuggestion这一项的key要改成enter才能用回车键选择，不然按回车是换行。。。

​赞
​回复
​踩
​举报
李健健
李健健10 天前
把enter和tab换一下，用enter来nextSuggestion，用tab来accept感觉更顺手