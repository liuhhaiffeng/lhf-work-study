# VSCode操作技巧

## 自定义主题风格

### 设置编辑区背景色为护眼色

个人喜欢在 Light+ (default light) 颜色主题下阅读代码,但此主题默认背景颜色是纯白色,长时间有些刺眼,因此想要修改为"豆沙绿"的护眼色.

**修改步骤如下:**
1 打开light_defaults.json文件

windows下默认路径:
```
C:\Users\Lenovo\AppData\Local\Programs\Microsoft VS Code\resources\app\extensions\theme-defaults\themes\light_defaults.json
```

linux下默认路径:
```
/usr/share/code/resources/app/extensions/theme-defaults/themes/light_defaults.json
```

2 将里面"editor.background"的值由纯白色(#FFFFFF)修改为豆沙绿(#CFE8CC)

3 重启vscode即可生效

### 函数粗体及函数参数高亮

在使用source insight工具阅读C语言代码时, 函数名称粗体显示, 函数参数高亮显示, 对于阅读代码比较方便. 而Light+ (default light)主题下默认没有此风格,自定义添加如下.

1 函数粗体显示

打开light_plus.json文件, 路径如下:
```
extensions\theme-defaults\themes\light_plus.json
```

在"settings"中增加"fontStyle": "bold"设置即可, 如下所示:

```json
	"settings": {
				"fontStyle": "bold",
				"foreground": "#795E26"
			}
```

2 函数参数高亮显示

同在light_plus.json文件中设置, 在文件后面追加一个设置. 如下, 在{"scope": "entity.name.label",}下面增加一个{"name": "Function argument",}的设置.

个人设置的风格如下:
a. fontStyle: 函数参数斜体显示
b. foreground: 函数参数橘黄色(#FD971F)高亮显示

```json
	   {
			"scope": "entity.name.label",
			"settings": {
				"foreground": "#000000"
			}
		},
		{
			"name": "Function argument",
			"scope": "variable.parameter",
			"settings": {
				"fontStyle": "italic",
				"foreground": "#FD971F"
			}
		}
```

## 操作技巧

### 全局搜索函数

按下  CTRL+T

在弹出的窗口中直接输入要查找的函数名称, 不区分大小写

### 全局搜索文件

CTRL+P

在弹出的窗口中直接输入要查找的文件名称, 不区分大小写

### 代码浏览 前进/后退

Windows下:

ALT+方向左键
ALt+方向右键

Linux下:

CTRL+ALT+-
CTRL+SHIFT+-

### 按下CTRL时, 鼠标悬浮查看更多预览

vscode下将鼠标放到函数或变量时可以预览其定义, 但只显示一行, 如果按下CTRL, 可以查看更多行的预览.

### 配对括号跳转 CTRL+SHIFT+\

### VSCode 删除当前行

CTRL+SHIFT+K

### vscode 左右缩进代码

CTRL+]    向左缩进一个Tab
CTRL+[    向右缩进一个Tab

### vscode 自动化格式代码

首先选中要格式化的内容

windows:  SHIFT + ALT + F
linux: CTRL + SHIFT + I

### vscode垂直选中列选中

VSCode列选择快捷键：ALT+SHIFT+鼠标左键

## 实用插件

Bookmarks
  Mark lines and jump to them

Bracket Pair Colorizer
Bracket Select
  ALT + a 选中当前{}中的内容

Markdown Preview Enhanced
  比vscode默认的markdown preview显示更好
Markdown TOC
  使得markdown有目录
markdownlint
  markdown语法检查和提示
Markdown All in One
  评分很高, 目前还不知道有什么用处.

Remote - SSH
Remote - SSH: Editing Configure Files
Remote - WSL

References++
  Show the results of "Find References' as formmatted text in an textor.

PrintCode
  Added printing function to VS Code!

hexdump for VSCode
  vscode下的十六进制显示, 有了它, 就不需要UtralEdit之类的编辑器了.

C/C++
  C/C++ IntelliSense, debugging, and code browsing.



### 主题插件

Atom One Dark Theme

> 名称: Atom One Dark Theme
> ID: akamud.vscode-theme-onedark
> 说明: One Dark Theme based on Atom
> 版本: 2.2.2
> 发布者: Mahmoud Ali
> VS Marketplace 链接: https://marketplace.visualstudio.com/items?itemName=akamud.vscode-theme-onedark

One Monokai Theme

> 名称: One Monokai Theme
> ID: azemoh.one-monokai
> 说明: A cross between Monokai and One Dark theme
> 版本: 0.5.0
> 发布者: Joshua Azemoh
> VS Marketplace 链接: https://marketplace.visualstudio.com/items?itemName=azemoh.one-monokai

### 其他

Back and Forward Buttons

> 名称: Back and Forward Buttons
> ID: baileyfirman.vscode-back-forward-buttons
> 说明: Navigate forwards and backwards using buttons in the status bar
> 版本: 1.0.1
> 发布者: Bailey Firman
> VS Marketplace 链接: https://marketplace.visualstudio.com/items?itemName=baileyfirman.vscode-back-forward-buttons

Fuzzy Tag For C/C++

> 名称: Fuzzy Tag For C/C++
> ID: joeylu-vscode.fuzzy-tag
> 说明: Fuzzy tag search based on Gtags
> 版本: 0.0.5
> 发布者: Joey Lu
> VS Marketplace 链接: https://marketplace.visualstudio.com/items?itemName=joeylu-vscode.fuzzy-tag

Header source switch

> 名称: Header source switch
> ID: ryzngard.vscode-header-source
> 说明: Header-source switcher for vscode
> 版本: 1.3.0
> 发布者: Andrew Hall
> VS Marketplace 链接: https://marketplace.visualstudio.com/items?itemName=ryzngard.vscode-header-source

highlight

> 名称: highlight
> ID: debugpig.highlight
> 说明: Highlight selected words
> 版本: 0.1.0
> 发布者: debugpig
> VS Marketplace 链接: https://marketplace.visualstudio.com/items?itemName=debugpig.highlight

select-highlight-cochineal-color

> 名称: select-highlight-cochineal-color
> ID: ebicochineal.select-highlight-cochineal-color
> 说明: select-highlight-cochineal-color
> 版本: 0.2.4
> 发布者: ebicochineal
> VS Marketplace 链接: https://marketplace.visualstudio.com/items?itemName=ebicochineal.select-highlight-cochineal-color



## 选中大括号内的内容  

需要对应插件的支持

Alt + a               			Bracket Select

Ctrl + Alt + a				Select Highlight  cochineal color



## 打开/关闭 终端

Ctrl + `



## 添加或删除 /*  */  样式的注释

Shift+Alt+a        按一下添加/*   */ 样式的注释,  再按一下取消

## 选中编辑区上部的函数

Ctrl+Shift+ ;     选中编辑区上部的函数

回车                 在回车, 即可达到函数下拉outline

## vscode 视图跳转(即 左侧, 下方和中间编辑器的按键跳转)

vscode的快捷键功能已经很丰富了, 丰富到几乎可以不用"vim插件"了. 其中各个视图的跳转也有对应的快捷键:

F6             顺时针跳转

Shfit-F6   逆时针跳转

## vscode vim 问题合集



### 如何解决VSCode Vim中文输入法切换问题？

作者：jackiexiao
链接：https://www.zhihu.com/question/303850876/answer/1421313587
来源：知乎
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。



对@良久 @somenzz 的回答做个**改进**和补充，可以做到**只在中文输入法的中英状态下**切换，解决切换到美式英文键盘不便的问题。

如果用的是neovim插件（前面是讲vscodevim），滚动到回答的最下方

2020-11-21 update，有3种方法

1. vscode-vim
2. vscode-neovim（第2种vim插件）
3. autohot key（原理是在vscode应用中，设置esc绑定到esc + 切换输入法） : https://www.zhihu.com/question/303850876/answer/1181682863

#### 1. vscode-vim

#### Linux&Mac-vscode-vim

[daipeihust/im-selectgithub.com![图标](https://pic1.zhimg.com/v2-4afed97d438132098cee9aa5e58a1e84_ipico.jpg)](https://link.zhihu.com/?target=https%3A//github.com/daipeihust/im-select%23linux-1)

我ubuntu16.04用了fcixt方法解决了

#### Windows

\1. 下载im-select.exe程序: [daipeihust/im-select](https://link.zhihu.com/?target=http%3A//chrome.google.com/webstore/category/extensions)

\2. 将im-select.exe 放到文件夹C:\im-select 下

\3. 进入cmder/powershell之类的终端（最快的方法是在 C:\im-select 文件夹下，shift+右键，出现一个在poworshell下打开）

\4. 分别切换你的输入法(中文 和英文) , 然后运行.\im-select.exe，理论上你应该得到两个不同的数字，比如我的英文是1033, 中文（搜狗输入法）是2052 

\5. 如果数字是一样的. 可能是因为你并没有切换不同语言的输入法(只是在同一个输入法下切换中英文) , 请进入你的输入法中设置一下：在设置中搜索`语言`，保证你有中文和英文两种语言，然后进入点击中文的语言，出现一个`选项`，然后在里头仅保留一个键盘（比如我的是保留搜狗输入法，删除微软拼音）,再回到第5步测试

\6. 如果你想更改输入法的切换快捷键，在设置中搜索`高级键盘设置`->`输入语言热键`->`更改按键设置`

\7. 设置**搜狗输入法的默认状态为英文**（其他输入法类似）（如果今后你发现失效了，大概率是因为默认状态不是英文（被重置回中文了））

\8. 最后回到vscode，ctrl+shift+p 输入 >Preferences: Open Settings (Json)，添加如下的配置就搞定了(1033要换成你的英文输入法在运行`im-select.exe`下对应的数字，2052类似)

```text
"vim.autoSwitchInputMethod.enable": true,
"vim.autoSwitchInputMethod.defaultIM": "1033",
"vim.autoSwitchInputMethod.obtainIMCmd": "C:\\im-select\\im-select.exe", 
"vim.autoSwitchInputMethod.switchIMCmd": "C:\\im-select\\im-select.exe {im} && C:\\im-select\\im-select.exe 2052"
```

\9. 原理是回到normal后切换2次输入法（1次到美式英文，1次回到搜狗，默认状态是英文），就达到了按Esc键回到搜狗英文状态的目的。



ps：你还可以在`window设置`中搜索`允许我为每个应用窗口使用不同的输入法`。开启之后系统就会记住你在不同窗口中采用的输入法（以及对应的中英状态），以减少中英文切换的次数。



> lhf备注: 上述windows生效的前提(以win10)为例, 除过搜狗输入法, 还要有一款"英文输入键盘", im-select才可生效.

> 即当按下"Win+Space"时, 输入法列表至少如下, im-select, 如果只有"搜狗中文输入法"或"win10自带的中文输入法", 那么im-select是不生效的, 切记切记.

>    中文简体 (搜狗中文输入法)

>    英语美国 (美式键盘)



#### 2. Neovim-vscode

在init.vim文件中加入

```text
autocmd InsertLeave * :silent :!C:\\im-select\\im-select.exe 1033 && C:\\im-select\\im-select.exe 2052
```

2052是搜狗输入法



### 决定放弃使用vscode vim

解决vscode vim输入法自动切换问题后, 在使用过程中, 还发现一个比较严重的问题, 至今没有解决, 导致最终放弃使用vscode vim.
问题描述: Ctrl+T 函数跳转后, 只要使用vim 的 k 或 j进行行移动, 那么其会立即回到"跳转之前的上一行或下一行", 即vscode vim 没有很好的解决, 在vscode中跳转后, k 或 j的正确行移动问题.