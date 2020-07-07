"说明: 此.vimrc为刘海峰自定义创建的文件

set nu    "显示行号
syntax on "启用自动语法高亮
set smarttab
set shiftwidth=4 "默认缩进4个空格
set tabstop=4 "使用tab时tab空格数
set softtabstop=4
set expandtab	"使用空格替换tab
set autoindent " 写代码时自动缩进使能
set smartindent
set linebreak   "vim分屏时, 长的行会自动折叠, 但完整的单词会被切断, 使用此设置后可解决此问题

" tags
" ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" 公共tags
set tags+=/usr/include/tags

"将各个目录下创建的tags文件添加到tags搜索列表中, 这样使用vi -t 时, 
"将会从tags列表中搜索, 直到遍历所有tags列表中的tags文件
"set tags+=$UXSRCHOME/tags
" ------------------------------------------------------------------

" 快捷键映射
" ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" 将ctrl-e映射为ctrl-j, 将ctlr-y映射为ctrl-k, 以方便使用
:map <C-j> <C-e>
:map <C-k> <C-y>

" https://blog.csdn.net/weialemon/article/details/78894221
"set mouse=a   " 默认开启  注: 有了下面的 j jzz  k kzz, 感觉set mouse=a可以不需要了, 故将其注释
map <silent><leader>mo :set mouse=a<cr>    " mo(mouse open) 打开vim 鼠标滚动和定位功能, 开启之后, 右键菜单和复制功能就没有了
map <silent><leader>mc :set mouse-=a<cr>   " mc(mouse close) 关闭vim 鼠标滚动和定位功能, 之后右键菜单和复制功能就可以使用了

" nnoremap就是在normal模式下生效
nnoremap j jzz
nnoremap k kzz

:map <esc><esc> :nohl<CR>
" 下面单个<esc>会有问题, 即 vi 打开文件后, 直接进入到了insert模式, " 所以还是用上面<esc><esc>吧
"map <esc> :nohl<CR>
" ------------------------------------------------------------------


" 为自定义文件类型添加语法高亮
" ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" vim 为新添加的文件后缀支持语法高亮
" 某个工程下的C代码都是以.pgc为后缀名命名的，
" 如果直接用默认配置的vim打开该文件，则vim不
" 认为这个文件时c文件，因此不会启动语法高亮。
" 解决办法如下:
au BufNewFile,BufRead *.pgc set filetype=c
au BufNewFile,BufRead *.smi set filetype=sql
au BufNewFile,BufRead *.std set filetype=sql
au BufNewFile,BufRead *.nc set filetype=sql
au BufNewFile,BufRead *.out set filetype=sql
" ------------------------------------------------------------------


" vim中复制粘贴缩进错乱问题解决
" 在vim中当使用ctrl+c,ctrl+v到vim时候, 会出现代码丢失和缩进错乱等情况
" 解决方案设置 set paste就OK了, vim默认是set nopaste (即: 解除了paste模式)
" paste模式主要帮我们做了如下事情：
" textwidth设置为0
" wrapmargin设置为0
" set noai
" set nosi
" softtabstop设置为0
" revins重置
" ruler重置
" showmatch重置
" formatoptions使用空值
" 注: set paste 和 set autoindent冲突, 开启set paste会使得set autoindent失效
" 上述问题解决: 不要永久性的打开set paster, 仅在vim中粘贴时,临时开启一下 
"set paste
" 总之如下:
"vim要粘贴的话，先set paste，然后粘贴，然后再set nopaste


"set cursorcolumn
"set cursorline
"默认的行选中是一条下划线,不好看,将其样式设置为bar-style
"缺点: 如果在uxsql中\! vi xx打开后, 就只显示文件名, 其他信息均没有显示
"highlight CursorLine   cterm=NONE ctermbg=black ctermfg=green guibg=NONE guifg=NONE

"下面2行让vim永久显示文件名
"set statusline=%F\ [%{&fenc}\ %{&ff}\ L%l/%L\ C%c]\ %=%{strftime('%Y-%m-%d\ %H:%M')} 
"https://blog.csdn.net/icbm/article/details/73028623
"set statusline=%F%m%r%h%w%=\ [ft=%Y]\ %{\"[fenc=\".(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\"+\":\"\").\"]\"}\ [ff=%{&ff}]\ [asc=%03.3b]\ [hex=%02.2B]\ [pos=%04l,%04v][%p%%]\ [len=%L]
set statusline=%F%m%r%h%w%=\ [pos=%04l,%04v][%p%%]\ [len=%L]
set laststatus=2

"参考: https://stackoverflow.com/questions/2019281/load-different-colorscheme-when-using-vimdiff
if &diff
    colorscheme desert
endif
au FilterWritePre * if &diff | colorscheme desert | endif

" ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"默认打开Taglist 
let Tlist_Auto_Open=0 
let Tlist_Show_One_File=1
let Tlist_Exit_OnlyWindow=1
let Tlist_WinWidth=40
"let Tlist_WinWidth=30
"vim中光标定位到一个函数内部时talist侧栏会显示当前所属的函数，不过默认刷新时间比较长，不太方便
set updatetime=200 " 我设置的是 2000 毫秒，即 2 秒 这样，Taglist 的刷新速度就接近 2 秒了
"let Tlist_Use_Horiz_Window=1  " 设置TagList横向显示
" 使用帮助
" x: 在TagList窗口中, 输入x 可以最大或最小创建查看 

" 可以用“:TlistOpen”打开taglist窗口，用“:TlistClose”关闭taglist窗口。或者使用“:TlistToggle”在打开和关闭间切换。
" 可以自定义快捷键，在我的vimrc中定义了下面的映射，使用“,tl”键就可以打开/关闭taglist窗口：
let mapleader=','   " 自定义 , 为<leader>
map <silent><leader>tl :TlistToggle<cr> 
" vim中taglist使用(比较详细的):  https://www.cnblogs.com/mo-beifeng/archive/2011/11/22/2259356.html
" -------------------------------------------------------------------

" https://blog.csdn.net/u012385733/article/details/79038973?utm_medium=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromMachineLearnPai2-1.nonecase&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromMachineLearnPai2-1.nonecase
"let g:winManagerWindowLayout = "TagList|FileExplorer"
"let g:winManagerWidth = 40
"nmap <silent><F10> :WMToggle<cr>
"let g:AutoOpenWinManager = 1
"map <silent><leader>wm :WMToggle<cr>

" +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" global, gtags, Gtags 介绍
"
" https://www.mankier.com/1/gtags
" If ´gtags.files´ exists in the current directory or a file is specified by
" the -f option, target files are limited by it. Lines starting with ´. ´ are
" comments.
"
" global: 参见 man global
" gtags:
"        gtags [-v]   全量更新
"        gtags -i[v]   增量更新
"
"        global -u[v] 增量更新  与 gtags -i[v] 功能等价, 其实 global -u[v] 内部就是调用 gtags -i[v]的
" vim中:
"    F2 : ccopen, F4: cclose
"    Gtags func: 查找函数定义
"    Gtags -r func: 查找函数的引用
"    Gtags -g pattern: 查找字符串, 注意不要添加双引号,会自动添加的
"    Gtags -gie patter: 查找字符串, 大小写敏感  https://www.cnblogs.com/kuang17/p/9449258.html
"    Gtags -s 查找未在gtags文件中的符号, 感觉比Gtags -g 能准确快速一些
"
"    注:1. -Ei  选项可以不区分大小写以及 .* 之类的模糊搜索
"       2. Gtags带有(单行的)自动提示时, 可以使用 CTRL-D, 进行窗口式的预览
"
map <silent><leader>cn :cn<cr>
map <silent><leader>cp :cp<cr>
map <silent><leader>cl :cl
map <silent><leader>cc :cc

" 查找func定义, 按下Tab会自动补全 
map <silent><leader>g :Gtags 

" 查找func的引用 -r (reference)
map <silent><leader>gr :Gtags -r <cr><cr>

map <silent><leader>gs :Gtags -s <cr><cr>

map <silent><leader>gP :Gtags -P 

" 查找字符串 -g (generation find)
map <silent><leader>gg :Gtags -g <cr><cr>
"map <silent> <leader>ggi :Gtags -gie 

map <silent> <leader>gd :Gtags <cr><cr>  
map <silent> <leader>gf :Gtags -f <cr><cr><F2>      

set cscopetag  " 使用 cscope作为 tags 命令
set cscopeprg='gtags-cscope' " 使用 gtags-cscope 代替 cscope
"gtags.vim 设置项
let GtagsCscope_Auto_Load = 1
let GtagsCscope_Auto_Map = 1
let GtagsCscope_Quiet = 1
let GtagsCscope_Ignore_Case=1

let Gtags_Close_When_Single=1   " 当查询结果只有一个时, 就不需要弹出quicklist窗口了
" -----------------------------------------------------------------

"在 vim的状态栏显示 当前行所在的函数名字, 按一下 f 键就能显示函数名字
fun! ShowFuncName()
    let lnum = line(".")
    let col = col(".")
    echohl ModeMsg
    echo getline(search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bW'))
    echohl None
    call search("\\%" . lnum . "l" . "\\%" . col . "c")
    endfun
    "这里f 和vim f 查找冲突了, 修改为 ,f
    "map f :call ShowFuncName() <CR>
    map <silent> <leader>f :call ShowFuncName() <CR>

" 其他使用tips
" q:      " 在normal模式下, 键入 q: 可以查看 :命令的历史
" q/      " 在normal模式下, 键入 q/ 可以查看搜索命令的历史
          "在弹出的历史命令窗口中, 选择要复用的命令后, 按下CTRL-C键, 即可将其复制到 :xx 或 /xx 中

" :e 打开文件, 使用 CTRL-D在quicklist大窗口中进行文件的预览,
          " 并且预览时可以过滤文件, 如: e *.c  然后CTRL-D, 则只显示所有扩展名为.c的文件

" vim 复制粘贴到命令行
" CTRL-R 0          " 即 先按下CTRL-R, 再按下数字0, 则可以将vim yy yaw yw 等的内容粘贴到vim命令行中了

" 搜索
" CTRL-] 跳转到函数的定义处
" gd  跳转到局部变量的定义处

" cd %:h  " 跳转到当前文件所在的目录

map <silent><leader>, :
map <silent><leader>,, :!

map <C-]> :Gtags <cr><cr>
