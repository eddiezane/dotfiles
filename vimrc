set nocompatible               " be iMproved
set encoding=utf-8
filetype off                   " required!

set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#rc()

" Bundles
Plugin 'gmarik/Vundle.vim'
Plugin 'fortes/vim-escuro'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/syntastic'
Plugin 'scrooloose/nerdcommenter'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'bling/vim-airline'
Plugin 'kien/ctrlp.vim'
" Plugin 'ervandew/supertab'
Plugin 'Valloric/YouCompleteMe'
Plugin 'airblade/vim-gitgutter'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'mattn/emmet-vim'
Plugin 'ZoomWin'
Plugin 'godlygeek/tabular'
Plugin 'taglist.vim'
Plugin 'iandoe/vim-osx-colorpicker'
Plugin 'ap/vim-css-color'

" All hail
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-ragtag'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-endwise'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-dispatch'

" Language specific
Plugin 'vim-ruby/vim-ruby'
Plugin 'kchmck/vim-coffee-script'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-haml'
Plugin 'slim-template/vim-slim'
Plugin 'mustache/vim-mustache-handlebars'
Plugin 'fatih/vim-go'
Plugin 'evanmiller/nginx-vim-syntax'
Plugin 'marijnh/tern_for_vim'

filetype plugin indent on

let Tlist_Ctags_Cmd='/usr/local/bin/ctags'

" Colors
colorscheme escuro
syntax on

" OSX color picker
let g:colorpicker_app = 'iTerm.app'

" Line numbers
set number
set numberwidth=1
set scrolloff=5
highlight LineNr ctermfg=245

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
nmap <leader>U mQviwU`Q
nmap <leader>L mQviwu`Q

" upper/lower first char of word
nmap <leader>u mQgewvU`Q
nmap <leader>l mQgewvu`Q

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

" YouCompleteMe settings"
let g:ycm_key_list_select_completion = ['<TAB>', '<Down>', '<Enter>']
let g:ycm_add_preview_to_completeopt = 0
let g:ycm_confirm_extra_conf = 0
set completeopt-=preview
let g:EclimCompletionMethod = 'omnifunc'
let g:ycm_auto_trigger = 0

cmap w!! w !sudo tee % >/dev/null

" Go fmt on write
" autocmd FileType go autocmd BufWritePre <buffer> Fmt
