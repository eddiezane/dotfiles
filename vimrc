set nocompatible               " be iMproved
set encoding=utf-8
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
Bundle 'bling/vim-airline'
Bundle 'kien/ctrlp.vim'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'fortes/vim-railscasts'
Bundle 'airblade/vim-gitgutter'
Bundle 'vim-ruby/vim-ruby'
Bundle 'kchmck/vim-coffee-script'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-ragtag'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-endwise'
Bundle 'tpope/vim-markdown'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-dispatch'
Bundle 'terryma/vim-multiple-cursors'
Bundle 'ervandew/supertab'
Bundle 'slim-template/vim-slim'
Bundle 'mattn/emmet-vim'
Bundle 'ZoomWin'
Bundle 'godlygeek/tabular'
Bundle 'FredKSchott/CoVim'

filetype plugin indent on

" Colors
colorscheme railscasts
syntax on

" Line numbers
set number
set numberwidth=1
set scrolloff=5
highlight LineNr ctermfg=240

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
nmap <leader>hn :noh<CR>
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

" Crutch
set mouse=a

" Clipboard
set clipboard+=unnamed

" Create fold from bracket
map <leader>zf zfaB

" NERD
let NERDRemoveExtraSpaces=1
let NERDSpaceDelims=1
map <Leader>n :NERDTreeToggle<CR>
map <leader>/ <plug>NERDCommenterToggle<CR>
imap <leader>/ <Esc><plug>NERDCommenterToggle<CR>i

" Statusline
set laststatus=2
let g:airline_powerline_fonts = 1
" if has("statusline") && !&cp
  " set laststatus=2  " always show the status bar

  " " Start the status line
  " set statusline=%f\ %m\ %r
  " set statusline+=Line:%l/%L[%p%%]
  " set statusline+=Col:%v
  " set statusline+=Buf:#%n
  " set statusline+=[%b][0x%B]
" endif

" Changes in buffer
function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()
map <leader>ds :DiffSaved<CR>

