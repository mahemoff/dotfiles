### SETTINGS
set -o vi

### STAPLE ALIASES
alias ..='cd ..'
alias bp='vi $HOME/.bash_profile'
alias sbp='. $HOME/.bash_profile'
alias a='vi $HOME/.bash_profile'
alias m=more
alias l=less
alias ll='ls -latr'
alias h='history|tail -10'
alias hi='history'
alias vi=vim
alias he=heroku

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

# UTILS
alias server='python -m SimpleHTTPServer'
typeset -fx tab{c,e,f,n,o,p} {,v}sp qa on
alias cront="VIM_CRONTAB=true /usr/bin/crontab -e"
function zipp { zip -r `basename $1`'.zip' $1 -x '*.git*'; }
function swp { mv -v `find . -name '*.sw?'` /tmp ; }
function ng { echo -e \\033c ; } # No Garbage (or use ctrl-o)

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

### LOCAL MACHINE SETTINGS
if [ -f $HOME/.bash_local ] ; then
  source $HOME/.bash_local
fi
