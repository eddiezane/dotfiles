set nocompatible               " be iMproved
set encoding=utf-8
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Bundles
Bundle 'gmarik/vundle'
Bundle 'fortes/vim-railscasts'
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/syntastic'
Bundle 'scrooloose/nerdcommenter'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'bling/vim-airline'
Bundle 'kien/ctrlp.vim'
Bundle 'ervandew/supertab'
Bundle 'airblade/vim-gitgutter'
Bundle 'terryma/vim-multiple-cursors'
Bundle 'mattn/emmet-vim'
Bundle 'ZoomWin'
Bundle 'godlygeek/tabular'
Bundle 'taglist.vim'

" All hail
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-ragtag'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-endwise'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-dispatch'

" Language specific
Bundle 'vim-ruby/vim-ruby'
Bundle 'kchmck/vim-coffee-script'
Bundle 'tpope/vim-markdown'
Bundle 'tpope/vim-haml'
Bundle 'slim-template/vim-slim'
Bundle 'mustache/vim-mustache-handlebars'
Bundle 'jnwhiteh/vim-golang'

filetype plugin indent off
set runtimepath+=$GOROOT/misc/vim
filetype plugin indent on

let Tlist_Ctags_Cmd='/usr/local/bin/ctags'

" Colors
colorscheme railscasts
syntax on

" Line numbers
set number
set numberwidth=1
set scrolloff=5
highlight LineNr ctermfg=240

" Crosshairs
hi CursorLine   cterm=NONE ctermbg=235
hi CursorColumn cterm=NONE ctermbg=235
nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>

" Automatically reload files
set autoread

" Don't wrap text
set nowrap

" Backspace
set backspace=indent,eol,start

" Soft tabs
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2

" upper/lower word
nmap <leader>u mQviwU`Q
nmap <leader>l mQviwu`Q

" upper/lower first char of word
nmap <leader>U mQgewvU`Q
nmap <leader>L mQgewvu`Q

" Highlighting
set hlsearch
nmap <leader>hs :set hlsearch! hlsearch?<CR>
highlight clear SignColumn

" Indent-Guides
au VimEnter * :IndentGuidesEnable
let g:indent_guides_auto_colors = 0
hi IndentGuidesEven ctermbg=233 guibg=#333333
hi IndentGuidesOdd ctermbg=black guibg=#2b2b2b

" 80-column line
if v:version >= 703
  set colorcolumn=81
  hi ColorColumn ctermbg=234
  hi ColorColumn guibg=grey15
else
  highlight OverLength ctermbg=red ctermfg=white guibg=#592929
  match OverLength /\%81v.\+/
endif

" Mouse crutch
set mouse=a

" Use system clipboard
set clipboard+=unnamed

" Toggle paste mode
set pastetoggle=<leader>p

" NERD
let NERDRemoveExtraSpaces=1
let NERDSpaceDelims=1
map <Leader>n :NERDTreeToggle<CR>
map <leader>/ <plug>NERDCommenterToggle<CR>
imap <leader>/ <Esc><plug>NERDCommenterToggle<CR>i

" Statusline
set laststatus=2
let g:airline_powerline_fonts = 1

" Go fmt on write
" autocmd FileType go autocmd BufWritePre <buffer> Fmt
