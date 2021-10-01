let &runtimepath.=',~/.config/vim'
set viminfo+=n$XDG_CACHE_HOME/vim/viminfo

"vim-plug -------------------------------------
if &compatible
  set nocompatible
endif
call plug#begin('~/.config/vim/bundle')
Plug 'embear/vim-localvimrc'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Shougo/denite.nvim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeTabsToggle' }
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-fugitive'
Plug 'jiangmiao/auto-pairs'
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-surround'
Plug 'cespare/vim-sbd'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'ajgon/vim-historic'
Plug 'sjl/gundo.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'SirVer/ultisnips'
Plug 'craigemery/vim-autotag'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf', { 'do': { -> fzf#install()  }  }
Plug 'junegunn/fzf.vim'
Plug 'morhetz/gruvbox'

" Terraform
Plug 'hashivim/vim-terraform', { 'for': ['tf', 'terraform'] }

" JS
Plug 'mustache/vim-mustache-handlebars', { 'for': ['mustache', 'html.mustache'] }

" PHP
"Plug 'lumiliet/vim-twig'

" Ruby
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
Plug 'tpope/vim-rails', { 'for': 'ruby' }
Plug 'tpope/vim-bundler', { 'for': 'ruby' }
Plug 'tpope/vim-rake', { 'for': 'ruby' }
Plug 'slim-template/vim-slim', { 'for': 'slim' }
Plug 'tpope/vim-rvm'

" Rust
Plug 'rust-lang/rust.vim', { 'for': 'rust' }

Plug 'janko-m/vim-test'
if executable('make') || executable('gmake')
  Plug 'Shougo/vimproc.vim', { 'do': 'make' }
endif

call plug#end()

" Filetypes:
filetype on
filetype indent on
filetype plugin on

" ADDS
let mapleader=","
" Paste from system clipboard (if terminal supports it)
if has('clipboard')
  nnoremap <Leader>v :set paste<CR>"*p :set nopaste<CR>
  vnoremap <Leader>c "*y
endif
nnoremap <Leader>s :w!<CR>
inoremap <Leader>s <Esc>:w!<CR>
"nnoremap <Leader>sq :wq!<CR>
nnoremap <Leader>q :qa<CR>
nnoremap <Leader>Q :qa!<CR>
" Indent code
nnoremap <Tab> >>
nnoremap <S-Tab> <<i
inoremap <S-Tab> <Esc><<i
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
" Ruby
nnoremap <Leader>rr :Rake<Space>
nnoremap <Leader>rrdm :Rake db:migrate<CR>
nnoremap <Leader>rrdc :Rake db:create<CR>
nnoremap <Leader>rrdd :Rake db:drop<CR>
nnoremap <Leader>rrds :Rake db:setup<CR>
nnoremap <Leader>rbi :Bundle install<CR>
nnoremap <Leader>rbu :Bundle update<CR>
nnoremap <Leader>rbo :Bopen<Space>
nnoremap <Leader>or !bundle exec overcommit -r<CR>
" Marked
nnoremap <Leader>b :silent !open -a Marked\ 2.app '%:p'<CR>:redraw!<CR>
" gundo
nnoremap <Leader>u :GundoToggle<CR>
" --------------------------
" Plugins config
" --------------------------
" vim-airline
let g:airline_theme="powerlineish"
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#show_tab_nr = 0
let g:airline_section_x = '%{airline#util#wrap(airline#parts#filetype(),0)} %{airline#util#wrap(ObsessionStatus(),0)}'
if executable('rvm')
  let g:airline_section_x = '%{airline#util#wrap(airline#parts#filetype(),0)} %{airline#util#wrap(rvm#statusline(),0)}'
endif

" NerdTree
let NERDTreeShowLineNumbers=0

" ultisnips
let g:UltiSnipsExpandTrigger="<C-;>"
let g:UltiSnipsJumpForwardTrigger="<C-tab>"
let g:UltiSnipsJumpBackwardTrigger=""
let g:UltiSnipsSnippetDirectories=["UltiSnips"]
let g:UltiSnipsEnableSnipMate=1
" vim-obsession
autocmd VimEnter * Obsession `~/.config/vim/vim-session-path.sh`

" EditorConfig
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" FZF
nnoremap <silent> <Leader>p :Files<CR>
nnoremap <silent> <Leader>P :Ag<CR>

" Unite Fuzzy find files
"nnoremap <silent> <Leader>p <C-W>l:Unite -auto-resize file_rec/async<cr>

"call unite#filters#matcher_default#use(['matcher_fuzzy'])
"call unite#filters#sorter_default#use(['sorter_rank'])
"let g:unite_split_rule = 'botright'
"let g:unite_enable_ignore_case = 1
"let g:unite_enable_smart_case = 1
"let g:unite_enable_start_insert = 1
"let g:unite_source_hisory_yank_enable = 1
"if executable('ag')
  "let g:unite_source_grep_command = 'ag'
  "let g:unite_source_grep_default_opts ='-i --smart-case --nogroup --nocolor'
  "let g:unite_source_grep_recursive_opt = ''
  "let g:unite_source_rec_async_command = ['ag', '--follow', '--nocolor', '--nogroup', '--hidden', '-g', '']
"endif

"call unite#custom#source('file_rec/async,file_rec/git', 'ignore_globs', [])
"nnoremap <C-P> :Unite file_mru file_rec/async file<CR>
"inoremap <C-P> <Esc>:Unite file_mru file_rec/async file<CR>
"hi link UniteCursorLine CursorLine
"hi UniteCursorLine cterm=NONE ctermbg=darkblue ctermfg=white guibg=darkblue guifg=white

"if executable('ack')
  "let g:unite_source_grep_command = 'ack'
  "let g:unite_source_grep_default_opts =
    "\ '-i --smart-case --nogroup --nocolor'
  "let g:unite_source_grep_recursive_opt = ''
  "let g:unite_source_rec_async_command =
    "\ 'ack -f --nofilter --nogroup --nocolor'
"endif

"call unite#filters#matcher_default#use(['matcher_fuzzy'])

"call unite#custom#profile('default', 'context', {
"\   'marked_icon': '✓',
"\   'start_insert': 1,
"\   'winheight': 10,
"\   'direction': 'botright',
"\   'cursor_line_highlight': 'UniteCursorLine'
"\ })

" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_ruby_checkers = ['mri', 'rubocop']
let g:syntastic_yaml_checkers = ['yamllint']
let g:syntastic_enable_highlighting = 0
highlight Search guibg=grey ctermbg=grey

" NERDTree
nnoremap <Leader>kb :NERDTreeTabsToggle<CR>
let NERDTreeShowHidden=1
let g:NERDTreeWinSize = 54
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" NERDCommenter
nmap <Leader>/ <Leader>c<space>
vmap <Leader>/ <Leader>c<space>

" NEOComplete
"let g:acp_enableAtStartup = 0
"let g:neocomplete#enable_at_startup = 1
"let g:neocomplete#enable_smart_case = 1
"let g:neocomplete#sources#syntax#min_keyword_length = 3
"let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
"let g:neocomplete#max_list = 10
"let g:neocomplete#enable_auto_select = 1
"set complete-=i

" vim-localvimrc
let g:localvimrc_persistent = 1

" vim-fugitive and vim-merginal
"nnoremap <silent> <Leader>gs :Gstatus<CR>
"nnoremap <silent> <Leader>gb :Gblame<CR>
"nnoremap <silent> <Leader>g/ :MerginalToggle<CR>
"set statusline+=%{fugitive#statusline()}
"nnoremap <C-G><C-S> :Gstatus<CR>
"inoremap <C-G><C-S> <Esc>:Gstatus<CR>

" vim-rvm
set shell=sh

" vim-test
nmap <silent> <Leader>t :TestNearest<CR>
nmap <silent> <Leader><Leader>t :TestLast<CR>
nmap <silent> <Leader><Leader>T :TestSuite<CR>
let test#strategy = "dispatch"
" vim-historic
let g:historicBackupRepoLocation = "~/.config/localhistory"
let g:historicBackupScriptLocation = "~/.config/vim/vim-historic-backup.sh"

" projectionist
nmap <silent> <Leader>T :A<CR>

" multicursor
"let g:multi_cursor_use_default_mapping=0
"let g:multi_cursor_next_key='<C-g>'
"let g:multi_cursor_quit_key='<Esc>'

" --------------------------
" Keybindings
" --------------------------
nnoremap <Leader>l    <C-W>l:bnext<CR>
"inoremap <C-C><Right>     <Esc>:bnext<CR>
nnoremap <Leader>h     <C-W>l:bprevious<CR>
"inoremap <C-C><Left>     <Esc>:bprevious<CR>
"nnoremap <C-c><C-s>     :w<CR>
"inoremap <C-c><C-s>     <Esc>:w<CR>
"nnoremap <C-c><C-q>     :qa<CR>
"inoremap <C-c><C-q>    <Esc>:qa<CR>
nnoremap <Leader>w     :Sbd<CR>
nnoremap <Leader>x     :Sbdm<CR>
nnoremap <Leader>W     :bd<CR>
nnoremap <Leader>X     :bd!<CR>
nnoremap <Leader>aw     :bufdo Sbd<CR>
nnoremap <Leader>ax     :bufdo Sbdm<CR>
nnoremap <Leader>aW     :bufdo bd<CR>
nnoremap <Leader>aX     :bufdo bd!<CR>
"inoremap <C-c><C-w>     <Esc>:bd<CR>
"nmap <Leader>j <C-W>j
"nmap <Leader>k <C-W>k
"nmap <Leader>h <C-W>h
"nmap <Leader>l <C-W>l
imap <C-j> <Esc><C-W>j
imap <C-k> <Esc><C-W>k
imap <C-h> <Esc><C-W>h
imap <C-l> <Esc><C-W>l
nmap <C-j> <Esc><C-W>j
nmap <C-k> <Esc><C-W>k
nmap <C-h> <Esc><C-W>h
nmap <C-l> <Esc><C-W>l

" --------------------------
" Other options
" --------------------------
" Encoding
set encoding=utf-8
set fileencoding=utf-8
" Display statusbar
set laststatus=2
" Color theme
if has("macunix")
  colorscheme Tomorrow-Night-Eighties
else
  set background=dark
  colorscheme gruvbox
  "autocmd vimenter * colorscheme gruvbox
endif
" Enable true color
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif
" Show line numbers
set number
set relativenumber
" Syntax highlighting
syntax on
" Tab width
set tabstop=4 shiftwidth=4 expandtab
" autocomplete vim commands
set wildmenu
" Cursor line
" set cursorline
" hi CursorLine cterm=underline
" Line Length limiter
" set Search results highlight
"hi Search cterm=NONE ctermbg=NONE guibg=NONE
" Allow to switch buffer without saving
set hidden
" Trim trailing whitespaces on save
autocmd BufWritePre * :%s/\s\+$//e
" Fix terminal
silent !stty -ixon > /dev/null 2>/dev/null
" Make search better
set incsearch
set hlsearch
noremap <Leader><space> :nohlsearch<CR>

set backspace=indent,eol,start

" cursorline and colorcolumn
" cursorline causes enormous scroll lag
"set cursorline
hi ColorColumn ctermbg=239 ctermfg=white guibg=darkgrey guifg=white
hi CursorLine ctermbg=239 cterm=none
hi CursorLineNr ctermfg=43 cterm=none
set colorcolumn=120

" I'm gonna hate myself for that
inoremap  <Up>     <NOP>
inoremap  <Down>   <NOP>
inoremap  <Left>   <NOP>
inoremap  <Right>  <NOP>
noremap   <Up>     <NOP>
noremap   <Down>   <NOP>
noremap   <Left>   <NOP>
noremap   <Right>  <NOP>

" Removing escape
inoremap jj <esc>
cnoremap jj <c-c>
vnoremap v <esc>

" Performance
set synmaxcol=200
set noshowmatch
set regexpengine=1
set lazyredraw
set ttyfast
set nofoldenable

" COC
" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
"if exists('*complete_info')
"  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
"else
"  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
"endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

let g:coc_config_home = '$XDG_CONFIG_HOME/vim/coc'
let g:coc_data_home = '$XDG_CONFIG_HOME/vim/coc'
let g:coc_global_extensions = 'coc-solargraph'
let g:coc_disable_startup_warning = 1

" Templates
let g:pathToTemplates='$XDG_CONFIG_HOME/vim/templates'
function! InsertTemplateSink(file)
  execute ':.-1read '.g:pathToTemplates.'/'.split(a:file, ':')[0]
endfunction

command! InsertTemplate call fzf#vim#grep('ag --nogroup --column --no-color .+', 0, { 'dir': g:pathToTemplates, 'sink': function('InsertTemplateSink') })
nnoremap <silent> <Leader>m :InsertTemplate<CR>
