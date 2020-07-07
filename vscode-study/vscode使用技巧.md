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



