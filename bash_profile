# Mahemoff's bash profile
# Some of this is taken from Linode default bashrc

### HELPER FUNCTIONS

function parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
#function quit() { echo "$*" 1>&2 ; exit 1; }
function quit() { echo "$*" ; exit 1; }

### LOCAL MACHINE - BEFORE
if [ -f $HOME/dotfiles/bash_before ] ; then
  source $HOME/dotfiles/bash_before
fi

### ENSURE WE'RE IN AN INTERACTIVE SHELL

[ -z "$PS1" ] && return

# SYSTEM
# change timezone w/ menu
function tz { sudo dpkg-reconfigure tzdata ; }
# non-interactive
#function tz { sudo timedatectl set-timezone $1 ; }
function tzl { timedatectl list-timezones ; }

### MONITORING AND ENV
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
function taif { tail -f ; }
function myip { curl http://checkip.amazonaws.com; }
function usage { top -b -n1 | egrep -i '(%cpu\(s\)|mem :|swap:)'; }
function orlogs { tail -f /usr/local/openresty/nginx/logs/*.log ; }
function syslogs { tail -f /var/log/messages/*.log ; }

function mon {
  #if [ $? -lt 2 ] ; then
    #quit "mon interval cmd"
  #fi
  interval=$1 && shift
  while [ 1 ] ; do
    echo `date`" running $*"          
    eval "$1"
    echo `date`" waiting ${interval}s"
    sleep $interval
    echo '--'
  done
}

# PATH
export DOTFILES="$HOME/dotfiles"

# Ruby path
#export PATH="$HOME/.rubies/ruby-2.3.5/bin:$PATH:$HOME/bin:$DOTFILES/bin"
export PATH="$HOME/.rubies/ruby-2.5.0/bin:$PATH:$HOME/bin:$DOTFILES/bin:~/.local/bin/"

# FINDING AND LISTING FILES
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
function duh { (cd ${1:-.} ; du -sh * | sort -h ; echo '--'; du -sh .) }

# SHELL OPTIONS
set -o vi
shopt -s checkwinsize # Sync window size with shell
#shopt -s globstar # Better globbing in file expansions
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)" # Binary less support

#### PROMPT
if [ "$OS" == 'linux' ] ; then
  export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
else
  export PS1="\u@\h:\w \[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty\[$txtrst\]\$ "
fi

#### TERMINAL

stty -ixon # disable antiquated freezing/resuming with ctrl-s/q
alias capsoff='xdotool key Caps_Lock' # fix weird caps on issue https://askubuntu.com/a/607915/40428

#### OPEN FILES
if [ "$OS" == 'linux' ] ; then
  alias open='xdg-open'
fi

#### HISTORY
export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTCONTROL=ignoredups # Avoid noisy history
shopt -s histappend # Append, don't overwrite, history, so all shells contribute it
_bash_history_sync() {
  builtin history -a         #1
  HISTFILESIZE=$HISTSIZE     #2
  builtin history -c         #3
  builtin history -r         #4
}
history() {                  #5
  _bash_history_sync
  builtin history "$@"
}
PROMPT_COMMAND=_bash_history_sync

### COLORIZE
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

### ALIASES

function hash {
  hasher=$(which md5sum)
  if [ -x "$hasher" ] ; then
    hashResult=`md5sum $1 |cut -f 1 -d " "`
  else # try osx
    hashResult=`md5 -q $1`
  fi
}

# CONFIG
function bp {

  file=$HOME/.bash_profile
  hash $file
  oldhash=$hashResult

  vi $file
  editStatus=$?
  hash $file
  newhash=$hashResult

  if [ $editStatus -ne 0 ] ; then
    echo "Quit editor, ignoring changes"
  elif [ "$newhash" == "$oldhash" ] ; then
    echo "No change"
  else
    echo "Applying bash profile"
    source $file
  fi

}

alias bpp='vi $HOME/.bash_profile'
alias sbp='source $HOME/.bash_profile'
alias ba='vi $HOME/.bash_after'
alias a='vi $HOME/.bash_profile'
function dotfiles {
  (cd ~/dotfiles ; git pull; ./make.sh)
  sbp
}

# MOVING BETWEEN DIRECTORIES
alias ..='cd ..'
alias pd='pushd'
alias po='popd'

# OUTPUTTING
alias m=more
alias md='mkdir'
alias l=less
alias ta='tail -fqn0'
alias ag='ag --silent'

# LISTING FILES (LS)
alias la='ls -AF'
alias ll='ls -latr'
alias lo='locate'
function wh { locate $1 | grep "$1$" ; }

# BASH HISTORY
alias h='history|tail -10'
alias hi='history'
function higrep { history | grep -i $1 | tail -5; }

# RUNNING APPS
function vi { vim.gtk3 $* || vim $* ; }
alias cront="VIM_CRONTAB=true /usr/bin/crontab -e"
alias ti='tig status'

### OPS
alias ans='ansible'
function ap {
  inventory=$1
  playbook=$2
  ansible-playbook -i $inventory $playbook $*
}
function ansplay { date ; ansible-playbook "$@" ; date ; }

### CLIPBOARD
alias xc='xclip -selection c'

### VIM
export EDITOR=vim
alias vm="vi $HOME/.vimrc"

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
alias bu=bundle
alias rake='bundle exec rake'
function blat { rake db:drop && rake db:create && rake db:migrate && rake db:schema:dump && rake db:fixtures:load && rake db:test:prepare; }
function migrate { bundle exec rake db:migrate && bundle exec rake db:test:prepare; }
alias bruby='bundle exec ruby'
alias brake='bundle exec rake'
alias brails='bundle exec rails'
alias ssbrails='spring stop; bundle exec rails'
alias ss='spring stop'
alias srake='RAILS_ENV=test spring rake'
alias stest='RAILS_ENV=test spring rails test'
alias sstest='spring stop; RAILS_ENV=test spring rails test'
#alias trake='RAILS_ENV=test spring rake test'
#alias trake='spring rails test' # can use -n /pattern/ too
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
function bunidev { bundle exec unicorn -c config/unicorn_dev.rb ; }
function buni { bundle exec unicorn -c config/unicorn.rb  -p $1; }
function sbuni { spring stop; bundle exec unicorn -c config/unicorn.rb  -p $1; }
alias buni3='buni 3000'
alias ssbuni3='spring stop; buni 3000'
alias buni4='buni 4000'
alias buni5='buni 5000'
function ct { ctags -R --exclude=.git --exclude=log * ~/.rvm/gems/ruby-head/* ; }
function rt { testable=$(echo 'test:'`echo $1 | sed 's/#/:/g'`) ; brake $testable; }
function pumas { pkill -9 -f 'puma 3.1'; sudo service puma restart; ps aux | grep puma ; }

# GO
export GOROOT=/usr/lib/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export PATH=$PATH:$HOME/.local/bin # python/pip/aws


# TMUX
function shell { tmux rename-window $1; ssh -o TCPKeepAlive=no -o ServerAliveInterval=15 $1; tmux rename-window 'bash'; }
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator
alias tmc="vi $HOME/.tmux.conf"
alias tx=tmux
alias tm=tmuxinator
tma='tmux attach'
function killtmux { tmux ls | awk '{print $1}' | sed 's/://g' | xargs -I{} tmux kill-session -t {} ; }
function tmuxsurvivor { tmux detach -a ; } # kill other tmuxes, needed to expand to fit resized window
# http://www.bendangelo.me/linux/2015/10/15/remap-caps-lock-in-ubuntu.html

# SSH/MOSH
# https://stackoverflow.com/a/39445896/18706
function killmoshes { pgrep mosh-server | grep -v $(ps -o ppid --no-headers $$) | xargs kill ; }

# GIT
#export GITAWAREPROMPT=$DOTFILES/projects/git-aware-prompt
#source $DOTFILES/projects/git-aware-prompt/main.sh
source $DOTFILES/bin/git-completion.bash
alias gco='git checkout'
alias gbr='git branch'
__git_complete co _git_checkout
alias ghard='git reset --hard HEAD'
alias gmerge='git merge'
alias gmerged='git branch --merged'
alias gnomerged='git branch --no-merged'
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
alias gnomerge='git merge --no-commit --no-ff'


trap_with_arg() { # from http://stackoverflow.com/a/2183063/804678
  local func="$1"; shift
  for sig in "$@"; do
    trap "$func $sig" "$sig"
  done
}

function handle_sigint() {
  for proc in `jobs -p` ; do kill $proc ; done
}

# JOBS
# ps search
function pss { ps aux | grep $1 | grep -v grep ; }

# WEB
# check same path on different hosts
# e.g. webcheck /about google.com google.co.uk
function webcheck {
  trap handle_sigint SIGINT
  set +m
  path=$1
  shift
  hosts=$*
  for host in $hosts ; do
    (
      echo $host
      for i in {1..5}; do
        echo $i

        bust=$(cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
        url="$host$path?$bust"
        message="$url\n"

        start=`ruby -e 'puts Time.now.to_f'`
        result=$(curl --silent -I $url | head -1)
        end=`ruby -e 'puts Time.now.to_f'`
        duration=$(bc <<< "$end-$start")
        message="$message$i. $duration -> $result\n"

      done
      printf "$message\n"
    ) &
  done 2>/dev/null
  wait
}

function perf {
  curl -o /dev/null  -s -w "%{time_connect} + %{time_starttransfer} = %{time_total}\n" "$1"
}

# POCKET
alias pocketadd='pockyt put -i'

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

function gitmvbranch {
	git branch -m $1 $2
	git push origin :$1
	git push --set-upstream origin $2
}

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

function gitdeploybump {
  git mvbranch master stable-1
  git mvbranch dev master
  git co master
  git co -b dev
}

function gitblastmerged {
  for branch in `git branch --merged | grep 'active/'` ; do
    target=`echo $branch | sed s/^active/old/g`
    git mvbranch $branch $target
  done
}

function gitpurge {
  git branch --merged | grep 'old/' | xargs git blast
}

function gitlogcopy { git log -1 --pretty=%B | pbcopy ; }

### OSX
if [ "$(uname)" == "Darwin" ]; then
  function iphonebackupdisable { defaults write com.apple.iTunes DeviceBackupsDisabled -bool true ; }
  function iphonebackupenable  { defaults write com.apple.iTunes DeviceBackupsDisabled -bool false ; }
  function startmysql { launchctl load ~/Library/LaunchAgents/com.mysql.mysqld.plist; }
  function stopmysql { launchctl unload ~/Library/LaunchAgents/com.mysql.mysqld.plist; }
  function flushdns { sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder; }
fi

### MYSQL

function mysql_rescue {
  sudo mkdir -p /var/run/mysqld
  sudo chown mysql:mysql /var/run/mysqld
  sudo /usr/sbin/mysqld --skip-grant-tables --skip-networking   
}

function mylong {
  min_time=${1:-10}
  display_width=${2:-160}
  filter=${3:-'$'} 
  echo "set @width=$display_width; select ID, USER, HOST, DB, COMMAND, TIME, STATE, concat(substr(INFO,1,@width),IF(LENGTH(INFO) > @width, ' ...', '')) as QUERY from INFORMATION_SCHEMA.PROCESSLIST where time > $min_time AND command <> 'Sleez' ORDER by time;" | mysql | grep $filter
}

function mytaillong {
  while [ 1 ]; do
    echo ''
    echo "[MySQL long] $(date)"
    mylong
    sleep 30
  done
}

function mykill { if [ "$1" != "" ] ; then (echo "kill $1" | mysql); fi }

# example: mykillpids 'clean up deletions' 123 456 789
function mykillpids {
  for mpid in $* ; do
    echo "$(date) Killing mysql pid $mpid"
    mykill $mpid
  done
}

function mykillall {
  min_time=$1
  shift
  pids=$(mylong $min_time | egrep "$*" | awk '{ print $1; }')
  if [ "$pids" != "" ] ; then
    mykillpids $pids
  fi
}

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

### TO CATEGORISE
function gzxml {
  gunzip -c $1 | xmllint --format -
}
function zipp { zip -r `basename $1`'.zip' $1 -x '*.git*'; }
function swp { mv -v `find . -name '*.sw?'` /tmp ; }
function callinfo {
  curl -I -s -w "%{time_connect} + %{time_starttransfer} = %{time_total}\n" "$1"
}
function ng { echo -e \\033c ; } # No Garbage (or use ctrl-o)
function yoink { wget -c -t 0 --timeout=60 --waitretry=60 $1 ; } # auto-resume
function recursive_sed { git grep -lz $1 | xargs -0 perl -i'' -pE "s/$1/$2/g" ; }


#[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Caps lock for tmux
# https://unix.stackexchange.com/a/241659/36161
#setxkbmap -layout us -option ctrl:nocaps
#xmodmap -e 'clear Lock'
#xmodmap -e 'keycode 0x7e = Control_R'
#xmodmap -e 'add Control = Control_R'

if [[ -n "$TMUX" ]] ; then
  source $HOME/dotfiles/bash_tmux
fi

