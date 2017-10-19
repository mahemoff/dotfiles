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
set modeline
set modelines=4
set nostartofline
set showcmd
set secure
set number

nmap Q gq
nmap <Leader>n <plug>NERDTreeTabsToggle<CR>
let NERDTreeShowHidden=1 " Show dotfiles
nmap T gT
nmap Y gt
nmap to :tabonly<cr>
map <Leader>s :NERDTreeFind<CR>
map <Leader>= <c-w>o:set nonumber<cr>
map <Leader>- <c-w>o:set number<cr>
map <Leader>a :Ag<space>

if has("mac")
  set clipboard=unnamed
elseif has("unix")
  set clipboard=unnamedplus
end

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

" https://gist.github.com/burke/5960456
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

" https://github.com/paradigm/dotfiles/blob/master/.vimrc#L104
" ------------------------------------------------------------------------------
"  " - cmdline-window_(mappings)
"  -
"  "
"  ------------------------------------------------------------------------------
"
"  " Swap default ':', '/' and '?' with cmdline-window equivalent.
" nnoremap : q:i
" xnoremap : q:i
" nnoremap / q/i
" xnoremap / q/i
" nnoremap ? q?i
" xnoremap ? q?i
" nnoremap q: :
" xnoremap q: :
" nnoremap q/ /
" xnoremap q/ /
" nnoremap q? ?
" xnoremap q? ?
"  " Have <esc> leave cmdline-window
" autocmd CmdwinEnter * nnoremap <buffer> <esc> :q\|echo ""<cr>

" ------------------------------------------------------------------------------
" Enhance command window
" http://vim.wikia.com/wiki/Enhanced_command_window
" ------------------------------------------------------------------------------

augroup ECW_au
  " musn't do au! again
  au CmdwinEnter : imap <UP> <C-O>y0<C-O>:let@/='^'.@0<CR><C-O>?<Esc><Esc>
  au CmdwinLeave : iunmap <UP>
  au CmdwinEnter : imap <DOWN> <C-O>y0<C-O>:let@/='^'.@0<CR><C-O>/<Esc><Esc>
  au CmdwinLeave : iunmap <DOWN>
  au CmdwinLeave : :let @/=""
augroup END

augroup ECW_au
  " musn't do au! again
  au CmdwinEnter : imap <C-D> <C-O>y0<C-O>:ECWCtrlD<CR><Esc>
  au CmdwinLeave : iunmap <C-D>
augroup END

function! s:ECWCtrlD()
  if (match(@", '^ *[a-z]\?map\s\s*\(\S\S*\)\?\s*$') >=0 )
    let s:foo = @"
    let save_more=&more
    set nomore
    execute ':redir @" |'.s:foo.'|redir END'
    let &more = save_more
    put=@"
    "Keep this next command even though Vim complains -- it is
    "a work-around for some "unknown bad thing"
    silent normal
    return
  endif
  "sf and find can have space separated arguments
  if (match(@", '^ *\(\(sf\)\|\(find\)\)\ *') >=0 )
    let s:foo = substitute(@", '^ *\(\(sf\)\|\(find\)\)\ *', '', '')
  else "pick the trailing non-space separated stuff
    let s:foo = substitute(@", '\(.\{-}\)\(\S\S*\s*\)$', '\2', '')
  endif
  let s:foo = substitute(s:foo, '\s*$', '*', '') "OK if ending has two wild-cards
  let @"=glob(s:foo)
  if(@" == "") | let @"='no match' | endif
  put=@"
endfunction

if !exists(":ECWCtrlD")
  command -nargs=0 ECWCtrlD call s:ECWCtrlD()
endif

" http://www.codeography.com/2013/06/19/navigating-vim-and-tmux-splits
if exists('$TMUX')
  function! TmuxOrSplitSwitch(wincmd, tmuxdir)
    let previous_winnr = winnr()
    silent! execute "wincmd " . a:wincmd
    if previous_winnr == winnr()
      call system("tmux select-pane -" . a:tmuxdir)
      redraw!
    endif
  endfunction

  let previous_title = substitute(system("tmux display-message -p '#{pane_title}'"), '\n', '', '')
  let &t_ti = "\<Esc>]2;vim\<Esc>\\" . &t_ti
  let &t_te = "\<Esc>]2;". previous_title . "\<Esc>\\" . &t_te

  nnoremap <silent> <C-h> :call TmuxOrSplitSwitch('h', 'L')<cr>
  nnoremap <silent> <C-j> :call TmuxOrSplitSwitch('j', 'D')<cr>
  nnoremap <silent> <C-k> :call TmuxOrSplitSwitch('k', 'U')<cr>
  nnoremap <silent> <C-l> :call TmuxOrSplitSwitch('l', 'R')<cr>
else
  map <C-h> <C-w>h
  map <C-j> <C-w>j
  map <C-k> <C-w>k
  map <C-l> <C-w>l
endif

 " Auto-save when switching to another tmux window \o/
let g:tmux_navigator_save_on_switch = 1

" restore cursor position
" https://askubuntu.com/questions/223018/vim-is-not-remembering-last-position
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

"let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --hidden
  "\ --ignore .git
  "\ --ignore .svn
  "\ --ignore .hg
  "\ --ignore .DS_Store
  "\ --ignore "**/*.pyc"'
