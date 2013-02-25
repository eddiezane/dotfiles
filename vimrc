set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Let Vundle manage Vundle. Required! 
Bundle 'gmarik/vundle'

" My Bundles here:
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/syntastic'
Bundle 'scrooloose/nerdcommenter'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'kien/ctrlp.vim'
Bundle 'fortes/vim-railscasts'
Bundle 'vim-ruby/vim-ruby'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-endwise'
Bundle 'ervandew/supertab'
Bundle 'tpope/vim-markdown'
Bundle 'slim-template/vim-slim'
Bundle 'ZoomWin'
filetype plugin indent on

" Colors
colorscheme railscasts
syntax on

" Line numbers
set number
set numberwidth=1
set scrolloff=5

" Automatically reload files
set autoread

" Don't wrap text
set nowrap

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

" Toggle hlsearch with <leader>hs
nmap <leader>hs :set hlsearch! hlsearch?<CR> 

" Indent-Guides
au VimEnter * :IndentGuidesEnable
let g:indent_guides_auto_colors = 0
hi IndentGuidesEven ctermbg=233 guibg=#333333
hi IndentGuidesOdd ctermbg=black guibg=#2b2b2b

" 80-column line
set colorcolumn=81
hi ColorColumn ctermbg=234
hi ColorColumn guibg=grey15

" Crutch
set mouse=a

" NERD
let NERDRemoveExtraSpaces=1
let NERDSpaceDelims=1
map <Leader>n :NERDTreeToggle<CR>
map <leader>/ <plug>NERDCommenterToggle<CR>
imap <leader>/ <Esc><plug>NERDCommenterToggle<CR>i

