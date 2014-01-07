Dotfiles
========

Unix dotfiles such as bash\_profile and vimrc, designed to be cloned onto new
machines. To bootstrap a new machine, git clone this and run make.sh, which
will set up the symlinks.

### Installing Vim Plugins

Based on
[this](http://endot.org/2011/05/18/git-submodules-vs-subtrees-for-vim-plugins/),
adding a new plugin looks like this:

    git subtree add --prefix vim/bundle/vim-fugitive https://github.com/tpope/vim-fugitive.git master --squash

And updating it looks like this:

    git subtree pull --prefix .vim/bundle/vim-fugitive https://github.com/tpope/vim-fugitive.git master --squash
