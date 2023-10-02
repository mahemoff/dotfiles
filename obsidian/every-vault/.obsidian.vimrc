# Force ourselves to get used to jk mapping
imap <Esc> <Nop>
# Escape mapping
imap jk <Esc>
" Quick save
imap jl <C-o>:w<Enter>

exmap togglefold obcommand editor:toggle-fold
nmap zo :togglefold
nmap zc :togglefold
nmap za :togglefold
