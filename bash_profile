# Mahemoff's bash profile
# Some of this is taken from Linode default bashrc

### ENSURE WE'RE IN AN INTERACTIVE SHELL

[ -z "$PS1" ] && return

# PATH
export PATH="$PATH:$HOME/bin"

### LOCAL MACHINE - BEFORE
if [ -f $HOME/dotfiles/bash_before ] ; then
  source $HOME/dotfiles/bash_before
fi

# SHELL OPTIONS
set -o vi
shopt -s checkwinsize # Sync window size with shell
shopt -s globstar # Better globbing in file expansions
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)" # Binary less support
PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

#### HISTORY
HISTCONTROL=ignoreboth # Avoid noisy hbistory
shopt -s histappend # Append, don't overwrite, history
HISTSIZE=1000
HISTFILESIZE=2000

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
alias server='python -m SimpleHTTPServer'
function zipp { zip -r `basename $1`'.zip' $1 -x '*.git*'; }
function swp { mv -v `find . -name '*.sw?'` /tmp ; }
function ng { echo -e \\033c ; } # No Garbage (or use ctrl-o)

# RUBY/RAILS
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function
rake='bundle exec rake'
function blat { rake db:drop && rake db:create && rake db:migrate && rake db:schema:dump && rake db:fixtures:load && rake db:test:prepare; }
alias brake='bundle exec rake'
alias bruby='bundle exec ruby'
alias brails='bundle exec rails'
alias brake='bundle exec rake'
alias assets='rake assets:precompile RAILS_ENV=production'
function buni { bundle exec unicorn_rails -p $1; }
alias buni3='buni 3000'
alias buni4='buni 4000'
alias buni5='buni 5000'
function ct { ctags -R --exclude=.git --exclude=log * ~/.rvm/gems/ruby-head/* ; }

# TMUX
function shell { tmux rename-window $1; ssh -o TCPKeepAlive=no -o ServerAliveInterval=15 $1; tmux rename-window 'bash'; }
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator
alias tm=~/prog/tmuxinator/bin/tmuxinator

### OSX
if [ "$(uname)" == "Darwin" ]; then
  function iphonebackupdisable { defaults write com.apple.iTunes DeviceBackupsDisabled -bool true ; }
  function iphonebackupenable  { defaults write com.apple.iTunes DeviceBackupsDisabled -bool false ; }
  function startmysql { launchctl load ~/Library/LaunchAgents/com.mysql.mysqld.plist; }
  function stopmysql { launchctl unload ~/Library/LaunchAgents/com.mysql.mysqld.plist; }
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
if [[ -n "$SSH_CLIENT" && -z "$TMUX" ]] ; then
  tmux has-session &> /dev/null
  if [ $? -eq 1 ]; then
    # default.yml can be a symlink to a preferred initial session
    if [ -f $HOME/.tmuxinator/default.yml ] ; then
      exec tmuxinator default
    else
      exec tmux new
      exit
    fi
  else
    exec tmux attach
    exit
  fi
fi
