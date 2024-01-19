set number
syntax on

set tabstop=2
set shiftwidth=2
set expandtab

set incsearch
set hlsearch
set ignorecase

set autoindent
set mouse=a

filetype plugin on

set encoding=utf-8

let NERDTreeWinPos = "left"
autocmd VimEnter * NERDTREE | wincmd p

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/syntastic'

call plug#end()
