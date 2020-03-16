
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

### 按下ctrl时, 鼠标悬浮查看更多预览

vscode下将鼠标放到函数或变量时可以预览其定义, 但只显示一行, 如果按下ctrl, 可以查看更多行的预览.

### 配对括号跳转 Ctrl+Shift+\

### 手动缩进 ctrl+] ctrl+[

### 自动缩进 shift+alt+F

## 实用插件

Bookmarks
Bracket Pair Colorizer
Markdown Preview Enhanced
Markdown TOC
Remote - SSH
Remote - WSL


