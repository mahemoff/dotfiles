# Mahemoff's bash profile
# Some of this is taken from Linode default bashrc

### ENSURE WE'RE IN AN INTERACTIVE SHELL

[ -z "$PS1" ] && return

# PATH
export PATH="$PATH:$HOME/bin:$HOME/dotfiles/bin"

### LOCAL MACHINE - BEFORE
if [ -f $HOME/dotfiles/bash_before ] ; then
  source $HOME/dotfiles/bash_before
fi

# SHELL OPTIONS
set -o vi
shopt -s checkwinsize # Sync window size with shell
#shopt -s globstar # Better globbing in file expansions
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)" # Binary less support
PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

#### HISTORY
export HISTCONTROL=ignoreboth # Avoid noisy hbistory
shopt -s histappend # Append, don't overwrite, history
export HISTSIZE=1000
export HISTFILESIZE=2000
export EDITOR=vim

### COLORIZE
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

### ALIASES
alias ..='cd ..'
alias bp='vi $HOME/.bash_profile'
alias sbp='. $HOME/.bash_profile'
alias a='vi $HOME/.bash_profile'
alias m=more
alias l=less
alias la='ls -AF'
alias ll='ls -latr'
alias h='history|tail -10'
alias hi='history'
alias vi=vim
alias he=heroku
alias cront="VIM_CRONTAB=true /usr/bin/crontab -e"
alias ti='tig status'
alias pd='pushd'
alias po='popd'
alias ag='ag --silent'
function zipp { zip -r `basename $1`'.zip' $1 -x '*.git*'; }
function swp { mv -v `find . -name '*.sw?'` /tmp ; }
function ng { echo -e \\033c ; } # No Garbage (or use ctrl-o)
function yoink { wget -c -t 0 --timeout=60 --waitretry=60 $1 ; } # auto-resume
function recursive_sed { git grep -lz $1 | xargs -0 perl -i'' -pE "s/$1/$2/g" ; }

# PYTHON
alias server='python -m SimpleHTTPServer'
export WORKON_HOME=$HOME/.virtualenvs
[ -f /usr/local/bin/virtualenvwrapper.sh ] && source /usr/local/bin/virtualenvwrapper.sh # see http://bit.ly/pyvirtualenv
# http://blog.doughellmann.com/2010/01/virtualenvwrapper-tips-and-tricks.html
alias v='workon'
alias v.deactivate='deactivate'
alias v.mk='mkvirtualenv --no-site-packages'
alias v.mk_withsitepackages='mkvirtualenv'
alias v.rm='rmvirtualenv'
alias v.switch='workon'
alias v.add2virtualenv='add2virtualenv'
alias v.cdsitepackages='cdsitepackages'
alias v.cd='cdvirtualenv'
alias v.lssitepackages='lssitepackages'

# RUBY/RAILS
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function
rake='bundle exec rake'
function blat { rake db:drop && rake db:create && rake db:migrate && rake db:schema:dump && rake db:fixtures:load && rake db:test:prepare; }
alias bruby='bundle exec ruby'
alias brake='bundle exec rake'
alias brails='bundle exec rails'
alias truby='RAILS_ENV=test bundle exec ruby'
alias trake='RAILS_ENV=test bundle exec rake'
alias trails='RAILS_ENV=test bundle exec rails'
alias assets='rake assets:precompile RAILS_ENV=production'
function buni { bundle exec unicorn_rails -p $1; }
alias buni3='buni 3000'
alias buni4='buni 4000'
alias buni5='buni 5000'
function ct { ctags -R --exclude=.git --exclude=log * ~/.rvm/gems/ruby-head/* ; }
function rt { testable=$(echo 'test:'`echo $1 | sed 's/#/:/g'`) ; brake $testable; }

# TMUX
function shell { tmux rename-window $1; ssh -o TCPKeepAlive=no -o ServerAliveInterval=15 $1; tmux rename-window 'bash'; }
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator
alias tx=tmux
alias tm=~/prog/tmuxinator/bin/tmuxinator
function killtmux { tmux ls | awk '{print $1}' | sed 's/://g' | xargs -I{} tmux kill-session -t {} ; }

### OSX
if [ "$(uname)" == "Darwin" ]; then
  function iphonebackupdisable { defaults write com.apple.iTunes DeviceBackupsDisabled -bool true ; }
  function iphonebackupenable  { defaults write com.apple.iTunes DeviceBackupsDisabled -bool false ; }
  function startmysql { launchctl load ~/Library/LaunchAgents/com.mysql.mysqld.plist; }
  function stopmysql { launchctl unload ~/Library/LaunchAgents/com.mysql.mysqld.plist; }
  function flushdns { sudo killall -HUP mDNSResponder ; }
fi

### META - MANAGING THIS DOTFILE PROJECT

# Example: addvimplugin https://github.com/scrooloose/nerdtree.git
function addvimplugin {
  cd $HOME/dotfiles
  repo=$1
  git subtree add --prefix vim/bundle/`basename $repo .git` $repo master --squash
}

function updatevimplugin {
  cd $HOME/dotfiles
  repo=$1
  git subtree pull --prefix vim/bundle/`basename $repo .git` $repo master --squash
}

### LOCAL MACHINE - AFTER
if [ -f $HOME/dotfiles/bash_after ] ; then
  source $HOME/dotfiles/bash_after
fi


# FINALLY, ENSURE TMUX SESSION FOR REMOTE SHELLS
# if [[ -n "$SSH_CLIENT" && -z "$TMUX" ]] ; then
  # tmux has-session &> /dev/null
  # if [ $? -eq 1 ]; then
    # # default.yml can be a symlink to a preferred initial session
    # if [ -f $HOME/.tmuxinator/default.yml ] ; then
      # exec tmuxinator default
    # else
      # exec tmux new
    # fi
    # exit
  # else
    # exec tmux attach
    # exit
  # fi
# fi

# Setup "inner" tmux settings, ie those inside a remote shell
# Default tmux prefix uses c-b so we use c-a when we detect we're in a remote tmux window
# This gets way better using Caps Lock for c-b and section key (§) for c-a ...
# Ideally, should only run this once per server instance (maybe using tmux -c after launch??)
#    maybe using if-shell 'test "$(uname)" = "Linux"' 'source ~/.tmux-linux.conf'
# See: https://gist.github.com/mahemoff/5288473
if [[ -n "$SSH_CLIENT" && -n "$TMUX" ]] ; then
  tmux unbind c-b
  tmux set -g prefix c-a > /dev/null
  tmux bind c-a send-prefix
  tmux set-window-option -g status-bg green > /dev/null
  tmux set-window-option -g status-fg black > /dev/null
  # https://gist.github.com/burke/5960455
  tmux bind C-c run "tmux save-buffer - | pbcopy-remote"
  tmux bind C-v run "tmux set-buffer $(pbpaste-remote); tmux paste-buffer"
fi

### OSX TMUX
if [[ "$(uname)" == "Darwin" && -n "$TMUX" ]] ; then
  tmux set-option -g default-command "reattach-to-user-namespace -l bash" > /dev/null
  tmux bind C-c run "tmux save-buffer - | reattach-to-user-namespace pbcopy"
  tmux bind C-v run "reattach-to-user-namespace pbpaste | tmux load-buffer - && tmux paste-buffer"
fi
