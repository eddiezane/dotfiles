call plug#begin('~/.config/nvim/plugged')

Plug 'tpope/vim-sensible'

" color scheme
Plug 'fortes/vim-escuro'

Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'mkitt/tabline.vim'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-ragtag'
Plug 'mattn/emmet-vim'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-fugitive'
Plug 'ConradIrwin/vim-bracketed-paste'
" Plug 'w0rp/ale'

" Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

Plug 'sheerun/vim-polyglot', { 'tag': '*' }
" Plug 'pangloss/vim-javascript'
" Plug 'mxw/vim-jsx'
" Plug 'HerringtonDarkholme/yats.vim'
" Plug 'hashivim/vim-terraform', { 'for': 'terraform' }

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'prettier/vim-prettier', {
  \ 'do': 'npm install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

call plug#end()

set nocompatible
set encoding=utf-8
set autoread
filetype plugin indent on
syntax on
colorscheme escuro

" Line numbers
set number
set scrolloff=5

set nowrap
nnoremap <leader>w :call WrapToggle()<cr>
function! WrapToggle()
  if(&wrap == 1)
    set nowrap
    set nolinebreak
  else
    set wrap
    set linebreak
  endif
endfunc

" Soft tabs
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬,space:.
nnoremap <leader>l :setlocal list!<cr>

" Highlighting
set hlsearch
nmap <leader>hs :set hlsearch! hlsearch?<CR>
highlight clear SignColumn

" Ignore some folders and files for CtrlP indexing
let g:ctrlp_custom_ignore = {
      \ 'dir':  '\.git$\|\.yardoc\|node_modules\|log\|tmp$',
      \ 'file': '\.so$\|\.dat$|\.DS_Store$'
      \ }

" NERD
let NERDRemoveExtraSpaces=1
let NERDTreeShowHidden=1
let NERDSpaceDelims=1
map <Leader>n :NERDTreeToggle<CR>
map <leader>/ <plug>NERDCommenterToggle<CR>
imap <leader>/ <Esc><plug>NERDCommenterToggle<CR>i

" http://vim.wikia.com/wiki/Disable_automatic_comment_insertion
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Statusline
set laststatus=2

" Forgot to edit with sudo
cmap w!! w !sudo tee % >/dev/null

" Prettier
nmap <Leader>py <Plug>(Prettier)
let g:prettier#exec_cmd_async = 1
let g:prettier#config#single_quote = 'true'
let g:prettier#config#semi = 'false'
let g:prettier#config#trailing_comma = 'es5'
let g:prettier#config#parser = 'typescript'

" coc.nvim
" extensions
let g:coc_global_extensions = [ 'coc-json', 'coc-yaml', 'coc-tsserver', 'coc-go' ]
" config
source $HOME/.config/nvim/coc-config.vim
