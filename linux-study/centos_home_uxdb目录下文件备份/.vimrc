"说明: 此.vimrc为刘海峰自定义创建的文件

set nu
syntax on "自动语法高亮

set smarttab
set shiftwidth=4 "默认缩进4个空格
set tabstop=4 "使用tab时tab空格数
set expandtab	"使用空格替换tab
set autoindent " 写代码时自动缩进使能

" 公共tags
set tags+=/usr/include/tags

"将各个目录下创建的tags文件添加到tags搜索列表中, 这样使用vi -t 时, 
"将会从tags列表中搜索, 直到遍历所有tags列表中的tags文件
"set tags+=$UXSRCHOME/tags

" 将ctrl-e映射为ctrl-j, 将ctlr-y映射为ctrl-k, 以方便使用
:map <C-j> <C-e>
:map <C-k> <C-y>

:map <esc><esc> :nohl<CR>
" 下面单个<esc>会有问题, 即 vi 打开文件后, 直接进入到了insert模式, " 所以还是用上面<esc><esc>吧
"map <esc> :nohl<CR>

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
"set paste

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


"set cursorcolumn
set cursorline
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

"默认打开Taglist 
let Tlist_Auto_Open=0 
let Tlist_Show_One_File=1
let Tlist_Exit_OnlyWindow=1
let Tlist_WinWidth=40
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

" https://blog.csdn.net/weialemon/article/details/78894221
"set mouse=a   " 默认开启
map <silent><leader>mo :set mouse=a<cr>    " mo(mouse open) 打开vim 鼠标滚动和定位功能, 开启之后, 右键菜单和复制功能就没有了
map <silent><leader>mc :set mouse-=a<cr>   " mc(mouse close) 关闭vim 鼠标滚动和定位功能, 之后右键菜单和复制功能就可以使用了

map <silent><leader>, :
map <silent><leader>,, :!

" ============================================================
"
" global, gtags, Gtags 介绍
"
" ============================================================
" global: 参见 man global
" gtags:
"        gtags -v   全量更新
"        gtags -i   增量更新
"
" vim中:
"    F2 : ccopen, F4: cclose
"    Gtags func: 查找函数定义
"    Gtags -r func: 查找函数的引用
"    Gtags -g pattern: 查找字符串, 注意不要添加双引号,会自动添加的
"    Gtags -gie patter: 查找字符串, 大小写敏感  https://www.cnblogs.com/kuang17/p/9449258.html
"    Gtags 
"
" Gtags cn and cp
"map <silent> <leader>cn :cn<cr>
"map <silent> <leader>cp :cp<cr>
map <silent> <leader>cn :cn<cr>
map <silent> <leader>cp :cp<cr>
map <silent> <leader>cl :cl
map <silent> <leader>cc :cc

" 查找func定义, 按下Tab会自动补全 
map <silent> <leader>g :Gtags
" 查找func的引用 -r (reference)
map <silent> <leader>gr :Gtags -r <cr><cr>
" 查找字符串 -g (generation find)
"map <silent> <leader>gg :Gtags -g 
"map <silent> <leader>ggi :Gtags -gie 

map <silent> <leader>gd :Gtags <cr><cr>  
" <F2> 的意思是列出所有的符号后, 并且光标跳转到 quicklist 窗口
map <silent> <leader>gf :Gtags -f <cr><cr><F2>      
"map <c-]> :Gtags <cr><cr>


set cscopetag  " 使用 cscope作为 tags 命令
set cscopeprg='gtags-cscope' " 使用 gtags-cscope 代替 cscope
"gtags.vim 设置项
let GtagsCscope_Auto_Load = 1
let GtagsCscope_Auto_Map = 1
let GtagsCscope_Quiet = 1


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

" ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" https://blog.csdn.net/qingdujun/article/details/81411197
set tabstop=4
set softtabstop=4
set shiftwidth=4

"set autoindent
set smartindent

"inoremap ' ''<ESC>i
"inoremap " ""<ESC>i
"inoremap ( ()<ESC>i
"inoremap [ []<ESC>i
"inoremap { {<CR>}<ESC>O
" --------------------------------------------------------

nnoremap j jzz
nnoremap k kzz
