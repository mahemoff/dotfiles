" Pathogen
filetype off " Pathogen needs to run before plugin indent on
call pathogen#incubate()
call pathogen#helptags() " generate helptags for everything in 'runtimepath'
filetype plugin indent on

let mapleader = ","
syntax on

set nocompatible
set wrap
set mouse=a
set ttym=xterm2
set ignorecase
set ruler
set scrolloff=999
set shiftwidth=2 tabstop=2 expandtab
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*.sassc
set backupdir=$HOME/.vim/_backup
set directory=$HOME/.vim/_tmp
set backup
set shell=bash
set gdefault
set modeline
set modelines=4
set nostartofline
set showcmd
set secure
set number

nmap Q gq
nmap <Leader>n <plug>NERDTreeTabsToggle<CR>
nmap T gT
nmap Y gt
nmap to :tabonly<cr>
map <Leader>s :NERDTreeFind<CR>
map <Leader>= <c-w>o:set nonumber<cr>
map <Leader>- <c-w>o:set number<cr>
map <Leader>a :Ag<space>

au FileType crontab set nobackup nowritebackup

" http://vim.wikia.com/wiki/Pretty-formatting_XML
function! DoPrettyXML()
  let l:origft = &ft
  set ft=
  1s/<?xml .*?>//e
  0put ='<PrettyXML>'
  $put ='</PrettyXML>'
  silent %!xmllint --format -
  2d
  $d
  silent %<
  1
  exe "set ft=" . l:origft
endfunction
command! PrettyXML call DoPrettyXML()

" https://gist.github.com/burke/5960455
function! PropagatePasteBufferToOSX()
  let @n=getreg("*")
  call system('pbcopy-remote', @n)
  echo "done"
endfunction
function! PopulatePasteBufferFromOSX()
  let @+ = system('pbpaste-remote')
  echo "done"
endfunction
nnoremap <leader>6 :call PopulatePasteBufferFromOSX()<cr>
nnoremap <leader>7 :call PropagatePasteBufferToOSX()<cr>

"let agprg="Ag --smart-case"

" https://github.com/paradigm/dotfiles/blob/master/.vimrc#L103
" ------------------------------------------------------------------------------
"  " - cmdline-window_(mappings)
"  -
"  "
"  ------------------------------------------------------------------------------
"
"  " Swap default ':', '/' and '?' with cmdline-window equivalent.
nnoremap : q:i
xnoremap : q:i
nnoremap / q/i
xnoremap / q/i
nnoremap ? q?i
xnoremap ? q?i
nnoremap q: :
xnoremap q: :
nnoremap q/ /
xnoremap q/ /
nnoremap q? ?
xnoremap q? ?
"  " Have <esc> leave cmdline-window
autocmd CmdwinEnter * nnoremap <buffer> <esc> :q\|echo ""<cr>
