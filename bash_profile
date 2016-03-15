# Mahemoff's bash profile
# Some of this is taken from Linode default bashrc

### ENSURE WE'RE IN AN INTERACTIVE SHELL

[ -z "$PS1" ] && return

# PATH
export DOTFILES="$HOME/DOTFILES"
export PATH="$PATH:$HOME/bin:$DOTFILES/bin"

### LOCAL MACHINE - BEFORE
if [ -f $DOTFILES/bash_before ] ; then
  source $DOTFILES/bash_before
fi

# SHELL OPTIONS
set -o vi
shopt -s checkwinsize # Sync window size with shell
#shopt -s globstar # Better globbing in file expansions
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)" # Binary less support
if [ "$OSTYPE" == 'LINUX' ] ; then
  #export PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w\$
  export PS1="\${debian_chroot:+(\$debian_chroot)}\u@\h:\w \[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty\[$txtrst\]\$ "
else
  export PS1="\u@\h:\w \[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty\[$txtrst\]\$ "
fi

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
alias ba='vi $HOME/.bash_after'
alias sbp='. $HOME/.bash_profile'
alias a='vi $HOME/.bash_profile'
alias m=more
alias md='mkdir'
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
alias lo='locate'
function wh { locate $1 | grep "$1$" ; }
function zipp { zip -r `basename $1`'.zip' $1 -x '*.git*'; }
function swp { mv -v `find . -name '*.sw?'` /tmp ; }
function perf {
  curl -o /dev/null  -s -w "%{time_connect} + %{time_starttransfer} = %{time_total}\n" "$1"
}

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
rake='bundle exec rake'
function blat { rake db:drop && rake db:create && rake db:migrate && rake db:schema:dump && rake db:fixtures:load && rake db:test:prepare; }
function migrate { bundle exec rake db:migrate && bundle exec rake db:test:prepare; }
alias bruby='bundle exec ruby'
alias brake='bundle exec rake'
alias brails='bundle exec rails'
alias ssbrails='spring stop; bundle exec rails'
alias ss='spring stop'
alias srake='RAILS_ENV=test spring rake'
alias trake='RAILS_ENV=test spring rake test'
alias sstrake='spring stop; RAILS_ENV=test spring rake test'
alias srails='spring rails'
alias ssrails='spring stop; brails'
alias ssrake='spring stop; brake'
#alias sbrails='spring stop; bundle exec rails'
#alias migrate='bundle exec rake migrate'
#function truby {
  # can use progress, outline, pretty, turn ...
  #RAILS_ENV=test bundle exec ruby $* --tapy | bundle exec tapout progress
#}
alias truby='RAILS_ENV=test bundle exec ruby'
alias tap='bundle exec tapout'
alias trails='RAILS_ENV=test bundle exec rails'
alias spr='spring stop'
alias strails='spring stop; RAILS_ENV=test bundle exec rails'
alias struby='spring stop; RAILS_ENV=test bundle exec ruby'
alias assets='rake assets:precompile RAILS_ENV=production'
#function buni { bundle exec unicorn_rails -p $1; }
function bunidev { bundle exec unicorn_rails -c config/unicorn_dev.rb ; }
function buni { bundle exec unicorn_rails -c config/unicorn.rb  -p $1; }
function sbuni { spring stop; bundle exec unicorn_rails -c config/unicorn.rb  -p $1; }
alias buni3='buni 3000'
alias ssbuni3='spring stop; buni 3000'
alias buni4='buni 4000'
alias buni5='buni 5000'
function ct { ctags -R --exclude=.git --exclude=log * ~/.rvm/gems/ruby-head/* ; }
function rt { testable=$(echo 'test:'`echo $1 | sed 's/#/:/g'`) ; brake $testable; }

# TMUX
function shell { tmux rename-window $1; ssh -o TCPKeepAlive=no -o ServerAliveInterval=15 $1; tmux rename-window 'bash'; }
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator
alias tx=tmux
alias tm=tmuxinator
tma='tmux attach'
function killtmux { tmux ls | awk '{print $1}' | sed 's/://g' | xargs -I{} tmux kill-session -t {} ; }

# GIT
export GITAWAREPROMPT=$DOTFILES/projects/git-aware-prompt
source $DOTFILES/projects/git-aware-prompt/main.sh
source $DOTFILES/bin/git-completion.bash
alias gco='git co'
__git_complete co _git_checkout
alias gmerge='git merge'
__git_complete merge _git_merge
GITS='add bisect branch checko clone commit diff fetch grep init log merge mv pull push rebase reset rm show status tag'
for cmd in `cat $DOTFILES/.git-commands.txt` ; do
  alias "g$cmd"="git $cmd"
  __git_complete $cmd _git_$cmd
done
alias gca='git commit -a'
function gc { git commit -a --message="$*" ; }
alias gd='git diff'
alias gl='git log'

# "private helper"
function vbump() {

  level=$1
  echo "LEVEL $level"
  semver inc $level
  if [ $? -ne 0 ] ; then
    echo 'semver script had a problem, exiting'
    exit 1
  fi

  shift
  message="${*:-bump}"
  echo "MESSAGE $message"

  echo "committing semver"
  git commit -a -m"$message ($level)"
  echo tagging
  git tag -a $(semver tag) -m "$message"
  echo showing tags
  git tag -n9 | grep `git describe` # show annotated
  echo pushing tags
  git push
  git push --tags
  #git push --follow-tags

}
function vpatch() { vbump patch $* ; }
function vminor() { vbump minor $* ; }
function vmajor() { vbump major $* ; }

# working on a general bump script
function gitpatch {
  message=$*
  branch=`git name-rev --name-only HEAD`
  git commit -a -m "$message"
  git push
  git checkout master
  git merge --no-edit $branch
  vpatch $message
  git checkout $branch
}

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

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
