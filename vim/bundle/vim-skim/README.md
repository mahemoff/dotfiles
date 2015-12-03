vim-skim
===

skim syntax highlighting for vim.



Install with vbundle
--------------------

1. [Install Vundle] into `~/.vim/bundle/`.

[Install Vundle]: https://github.com/gmarik/vundle#quick-start

        mkdir -p ~/.vim/bundle; pushd ~/.vim/bundle; \
        git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
        popd

2. Configure your vimrc for Vundle. Here's a bare-minimum vimrc that enables vim-skim :


    ```vim
    set rtp+=~/.vim/bundle/vundle.vim
    call vundle#begin()

    Plugin 'gaogao1030/vim-skim'
    
    call vundle#end()

    syntax enable
    filetype plugin indent on
    ```

If you're adding Vundle to a built-up vimrc, just make sure all these calls
   are in there and that they occur in this order.

3. Open vim and run `:PluginInstall`.

To update, open vim and run `:PluginInstall!` (notice the bang!)
