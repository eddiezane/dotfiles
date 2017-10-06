set nocompatible               " be iMproved
set encoding=utf-8
filetype off                   " required!

" Vundle bootstrap
let iCanHazVundle=1
let vundle_readme=expand('~/.vim/bundle/Vundle.vim/README.md')
if !filereadable(vundle_readme)
  echo "Installing Vundle.."
  echo ""
  silent !mkdir -p ~/.vim/bundle
  silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/Vundle.vim
  let iCanHazVundle=0
endif

set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()

" Bundles
Plugin 'gmarik/Vundle.vim'

Plugin 'fortes/vim-escuro'
" Plugin 'ajh17/Spacegray'
" Plugin 'altercation/vim-colors-solarized'
" Plugin 'roosta/srcery'

" Plugin 'guns/xterm-color-table.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/syntastic'
Plugin 'scrooloose/nerdcommenter'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'airblade/vim-gitgutter'
" Plugin 'terryma/vim-multiple-cursors'
Plugin 'mattn/emmet-vim'
" Plugin 'ZoomWin'
Plugin 'godlygeek/tabular'
" Plugin 'taglist.vim'
" Plugin 'iandoe/vim-osx-colorpicker'
" Plugin 'ap/vim-css-color'
" Plugin 'AndrewRadev/splitjoin.vim'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'jiangmiao/auto-pairs'
Plugin 'mkitt/tabline.vim'
Plugin 'mileszs/ack.vim'

" All hail
" Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-ragtag'
Plugin 'tpope/vim-fugitive'
" Plugin 'tpope/vim-endwise'
Plugin 'tpope/vim-surround'
" Plugin 'tpope/vim-dispatch'
Plugin 'tpope/vim-sensible'

" Language specific
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-markdown'
" Plugin 'tpope/vim-haml'
" Plugin 'slim-template/vim-slim'
" Plugin 'mustache/vim-mustache-handlebars'
Plugin 'fatih/vim-go'
" Plugin 'marijnh/tern_for_vim'
" Plugin 'elixir-lang/vim-elixir'
" Plugin 'rust-lang/rust.vim'

" Plugin 'guns/vim-clojure-static'
" Plugin 'tpope/vim-fireplace'

" JavaScript
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
" Plugin 'leafgarland/typescript-vim'
" Plugin 'HerringtonDarkholme/yats.vim'
Plugin 'prettier/vim-prettier'
" Plugin 'jelera/vim-javascript-syntax'
" Plugin 'othree/yajs'
" Plugin 'othree/es.next.syntax.vim'
" Plugin 'gavocanov/vim-js-indent'
" Plugin 'rschmukler/pangloss-vim-indent'

" Plugin 'osyo-manga/vim-monster'
" Plugin 'Shougo/vimproc.vim'

Plugin 'SirVer/ultisnips'

" Plugin 'easymotion/vim-easymotion'

call vundle#end()

" Bootstrap plugin install
if iCanHazVundle == 0
  echo "Installing Bundles, please ignore key map error messages"
  echo ""
  :PluginInstall
  " !~/.vim/bundle/YouCompleteMe/install.py --clang-completer --tern-completer --gocode-completer
endif

filetype plugin indent on

" Spell check
nnoremap <Leader>sp :setlocal spell spelllang=en_us<CR>
au BufRead *.txt,*.md setlocal spell
nnoremap <Leader>nsp :set nospell<CR>

" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-b>"
let g:UltiSnipsEditSplit="vertical"

let Tlist_Ctags_Cmd='/usr/local/bin/ctags'

" Colors
syntax on

colorscheme escuro

" colorscheme srcery
" set background=dark

" colorscheme solarized
" set background=light
" let g:solarized_termcolors=256

" OSX color picker
" let g:colorpicker_app = 'iTerm.app'

" Line numbers
set number
set numberwidth=1
set scrolloff=5

nnoremap <leader>g :call NumberToggle()<cr>
function! NumberToggle()
  if(&relativenumber == 1)
    set norelativenumber
  else
    set relativenumber
  endif
endfunc

highlight LineNr ctermfg=245

" Crosshairs
hi CursorLine   cterm=NONE ctermbg=235
hi CursorColumn cterm=NONE ctermbg=235
nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>

" Automatically reload files
set autoread

" Don't wrap text
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

" New tab
nmap <leader>t :tabedit<cr>

" Shortcut to rapidly toggle `set list`
" nmap <leader>l :set list!<CR>

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬,space:.
nnoremap <leader>l :setlocal list!<cr>

function! TrimWhitespace()
    let l:save = winsaveview()
    %s/\s\+$//e
    call winrestview(l:save)
endfunction

autocmd BufWritePre *.rb,*.mote,*.js :call TrimWhitespace()

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
" set mouse=a

" Toggle paste mode
set pastetoggle=<leader>p

" Toggle system clipboard
nnoremap <leader>C :call ToggleSystemClip()<cr>

function! ToggleSystemClip()
  if &clipboard == "unnamed"
    set clipboard-=unnamed
    echom "SysClip Off"
  else
    set clipboard=unnamed
    echom "SysClip On"
  endif
endfunction

" Ignore some folders and files for CtrlP indexing
let g:ctrlp_custom_ignore = {
      \ 'dir':  '\.git$\|\.yardoc\|node_modules\|log\|tmp$',
      \ 'file': '\.so$\|\.dat$|\.DS_Store$'
      \ }

" NERD
let NERDRemoveExtraSpaces=1
let NERDSpaceDelims=1
map <Leader>n :NERDTreeToggle<CR>
map <leader>/ <plug>NERDCommenterToggle<CR>
imap <leader>/ <Esc><plug>NERDCommenterToggle<CR>i

" http://vim.wikia.com/wiki/Disable_automatic_comment_insertion
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Statusline
set laststatus=2
let g:airline_powerline_fonts = 1

" YouCompleteMe settings
let g:ycm_key_list_select_completion = ['<TAB>', '<Down>']
let g:ycm_add_preview_to_completeopt = 0
let g:ycm_auto_trigger = 0
nnoremap <Leader>yd :YcmCompleter GetDoc <CR>
nnoremap <Leader>yt :YcmCompleter GetType <CR>
" let g:ycm_autoclose_preview_window_after_completion = 1
" let g:ycm_confirm_extra_conf = 0
set completeopt-=preview

" Forgot to edit with sudo
cmap w!! w !sudo tee % >/dev/null

let g:jsx_ext_required = 0 " Allow JSX in normal JS files
" let g:user_emmet_settings = {'html':{'quote_char': "'",},}"'"}}

" Prettier
nmap <Leader>py <Plug>(Prettier)
let g:prettier#exec_cmd_async = 1
let g:prettier#config#semi = 'false'
let g:prettier#config#bracket_spacing = 'true'
let g:prettier#config#trailing_comma = 'none'

" Auto pairs
let g:AutoPairsShortcutToggle='<leader>a'
