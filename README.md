Dotfiles
========

Mahemoff's Unix dotfiles such as bash\_profile and vimrc, designed to be cloned
onto new machines. To bootstrap a new machine, git clone this and run make.sh,
which will set up the symlinks.

### Basic setup

```
git clone git@github.com:mahemoff/dotfiles.git
dotfiles/make.sh
```

### Installing Vim Plugins

Based on
[this](http://endot.org/2011/05/18/git-submodules-vs-subtrees-for-vim-plugins/),
adding a new plugin looks like this:

    git subtree add --prefix vim/bundle/vim-fugitive https://github.com/tpope/vim-fugitive.git master --squash

And updating it looks like this:

    git subtree pull --prefix .vim/bundle/vim-fugitive https://github.com/tpope/vim-fugitive.git master --squash
    
### Recommended tools

To enhance your scripting pleasure, these tools are recommended:

```
apt install git tig mycli mosh pv
```

### License

The MIT License (MIT)

Copyright (c) from 2013, Michael Mahemoff

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
