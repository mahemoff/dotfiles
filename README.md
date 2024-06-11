Dotfiles
========

Mahemoff's Unix dotfiles such as bash\_profile and vimrc, designed to be cloned
onto new machines.

Instructions below are optimised for recent versions of Ubuntu.

# Setup

## Git

You'll need github access to clone the repo, so install git:

```
apt install git
```

Generate a new ssh key:

```
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub
```

Now log into https://github.com/settings/keys and click "New SSH Key", pasting the pub key output from above as a new key.

## Install dotfiles

```
git clone git@github.com:mahemoff/dotfiles.git
dotfiles/make.sh
```

## Install cool tools

Install recommended tools:

```
apt install vim-gtk3 tmux git tig mycli mosh pv tig httpie
```

## Install window manager and terminal tools

Alacritty and Zellij  don't yet have standard apt packages and rely on rust, therefore need rustup and a bunch of tools suggested by [alacritty docs](https://github.com/alacritty/alacritty/blob/master/INSTALL.md).

```
apt install i3 rofi rustup build-essential cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
cargo install alacritty zellij
```

For modern terminal muxing on a desktop PC, use:

```
cargo install alacritty
cargo install zellij
```

# Maintenance

## Updating dotfiles

Dotfiles are kept in dotfiles folder and symlinked - by the make.sh screipt - to the location expected by the shell, e.g. dotfiles/bash_profile. Therefore you can just edit dotfiles as normal, e.g. `vi ~/.bash_profile` or can also edit it in the dotfiles folder `vi ~/dotfile/bash_profile` ... same thing either way. Remember to push changes after updates that are meant to be persisted.

For changes that are specific to the install, there are additional sourced files that are git-ignored, e.g. `dotfiles/bash_after`.

## Installing Vim Plugins

Based on
[this](http://endot.org/2011/05/18/git-submodules-vs-subtrees-for-vim-plugins/),
adding a new plugin looks like this:

    git subtree add --prefix vim/bundle/vim-fugitive https://github.com/tpope/vim-fugitive.git master --squash

And updating it looks like this:

    git subtree pull --prefix .vim/bundle/vim-fugitive https://github.com/tpope/vim-fugitive.git master --squash

## Specialised setup

[MySQL tuning](https://gist.github.com/mahemoff/24a5a68e4d6b1f385af7826d195d79f0)

# License

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
