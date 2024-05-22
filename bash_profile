#"quick commit"  Mahemoff's bash profile
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

#[ -z "$PS1" ] && return

# SYSTEM
# change timezone w/ menu
function tz { sudo dpkg-reconfigure tzdata ; }
# non-interactive
#function tz { sudo timedatectl set-timezone $1 ; }
function tzl { timedatectl list-timezones ; }

### MONITORING AND ENV
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
function taif { tail -f ; } # tail live file
function taifg { tail -f | sed G; } # tail live file with empty line after each line
function myip { curl http://checkip.amazonaws.com; }
function usage { top -b -n1 | egrep -i '(%cpu\(s\)|mem :|swap:)'; }
function orlogs { tail -f /usr/local/openresty/nginx/logs/*.log ; }
function syslogs { tail -f /var/log/messages/*.log ; }
# measure rate a file (such as logfile) is growing
function filespeed { 
  file=$1
  delay=${2:-5}
  start=$(wc -l log/production.log | cut -d' ' -f1)
  sleep $delay
  stop=$(wc -l log/production.log |cut -d' ' -f1)
  rate=$(( ($stop - $start) / $delay ))
  echo "$rate lines/s"
}
# https://stackoverflow.com/a/57325221/18706
alias cleanstrings="sed $'s#\e[\[(][[:digit:]]*[[:print:]]##g'|strings"

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
function path { echo "${PATH//:/$'\n'}" | sort; } # show path separated by newlines

# FILES
alias chx='chmod u+x'

# Ruby path
#export PATH="$HOME/.rubies/ruby-2.3.5/bin:$PATH:$HOME/bin:$DOTFILES/bin"
#export PATH="$HOME/.rubies/ruby-2.6.5/bin:$PATH:$HOME/bin:$DOTFILES/bin:~/.local/bin/"

# Java/Gradle
export GRADLE_HOME=/opt/gradle/gradle-5.0

# FINDING AND LISTING FILES
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
function duh { (cd ${1:-.} ; du -sh * | sort -h ; echo '--'; du -sh .) }
function dfh { df -h ${1:-.} ; }

# STATS ON FILES
function wch { printf "%'d\n" $(wc -l < $1 );  } # human-readable wc (macos doesn't support -h)

# SHELL OPTIONS
shopt -s checkwinsize # Sync window size with shell
#shopt -s globstar # Better globbing in file expansions
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)" # Binary less support

# SHELL VI MODE
# See also inputrc as we are mapping jk to <esc>
set -o vi
#bind -m vi-insert "\C-x": self-insert
#bind -m vi-insert "\C-j": "\C-x\C-j"

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
#_bash_history_sync() {
  #builtin history -a         #1
  #HISTFILESIZE=$HISTSIZE     #2
  #builtin history -c         #3
  #builtin history -r         #4
#}
#history() {                  #5
  #_bash_history_sync
  #builtin history "$@"
#}
#PROMPT_COMMAND=_bash_history_sync

### HELP/DOCS
function tl { tldr $* | more ; }

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
alias SBP=sbp
alias rbp='nocaps; source $HOME/.bash_profile' # "reset" mode to force nocaps
alias RBP=rbp
function bpg { rg $@ $HOME/.bash_profile; }
alias ba='vi $HOME/.bash_after'
alias bt='vi $HOME/.bash_tmux'
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
export BAT_THEME='TwoDark' # for bat, alternative to cat
function lmd { pandoc doc/design/design.md | lynx -stdin ; }

# LISTING FILES (LS)
alias la='ls -AF'
alias ll='ls -latr'
alias lsr='ls -laSr' # sort by file size
alias lo='locate'
function wh { locate $1 | grep "$1$" ; }

# MOUNTING
alias mo='mount'
alias um='unmount'

# BASH HISTORY
alias h='history|tail -10'
alias hi='history'
function histgrep { history | grep -i $1 ; }
function higrep { history | grep -i $1 | tail -5; }

# RUNNING APPS
#function vi { (vim.gtk3 $* > /dev/null) || vim $* ; }
#function vi { vim $* ; } 
alias vi=vim

# vim with support for line number specified by colon
VIM=$(which vim)
function vi {
	local args
	IFS=':' read -a args <<< "$1"
	"$VIM" "${args[0]}" +0"${args[1]}"
}
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

### OBSIDIAN
export OBSIDIAN_VAULT_ROOT="$HOME/Documents/obsidian"
# https://forum.obsidian.md/t/vim-enable-key-repeat-option/1095/7 - Vim repeat mode
if [ "$(uname)" == "Darwin" ]; then
  defaults write md.obsidian ApplePressAndHoldEnabled -bool false
fi

# https://stackoverflow.com/a/17986639/18706
# "vi new" alias to idempotently create and start editing the file at any path
# e.g. vin foo/bar/baz makes new foo/bar folder and the file
function vin {
  file=$1
  shift
  echo $file
  folder=$(sed 's/\(.*\)\/.*/\1/' <<< $file)
  mkdir -p $folder
  if [ "$1" == "chmodx" ]; then
    shift
    echo chmoding
    chmod u+x $file
  fi
  vi $@ $file
}

function vinx { 
  vin $1 chmodx
}

# https://news.ycombinator.com/item?id=22293133
function nb {
  notes=$HOME/Dropbox/pers/notes.txt
  if [ -f $notes ] ; then
    echo >> $notes
    date >> $notes
    echo $@ >> $notes
    vim "+normal Go" +startinsert $notes
  else
    echo "$notes not found"
  fi
}

# PYTHON
alias httpserver='python -m SimpleHTTPServer'
export WORKON_HOME=$HOME/.virtualenvs
alias py='python3.9'
#alias pipinstall='py -m pip install -r requirements.txt'
alias pipinstall='py -m pip install'
alias pipfreeze='py -m pip freeze > requirements.txt'
alias pipreq='py -m pip install -r requirements.txt'
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
alias be='bundle exec'
alias bruby='bundle exec ruby'
alias brake='bundle exec rake'
alias brass='brake assets:precompile'
alias brails='bundle exec rails'
alias ssbrails='spring stop; bundle exec rails'
alias ss='spring stop'
alias srake='RAILS_ENV=test spring rake'
alias stest='RAILS_ENV=test spring rails test'
function pest { processes=${1:-8}; echo "$processes procs"; RAILS_ENV=test PARALLEL_TEST_FIRST_IS_1=true brake "parallel:test[$processes]" ; }
alias sstest='spring stop; RAILS_ENV=test spring rails test'
#alias trake='RAILS_ENV=test spring rake test'
#alias trake='spring rails test' # can use -n /pattern/ too
alias sstrake='spring stop; RAILS_ENV=test spring rake test'
alias srails='spring rails'
alias rgmigration='spring rails g migration'
alias rmigrate='spring rake db:migrate'
alias rrollback='spring rake db:rollback'
alias rredo='spring rake db:migrate:rollback'
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

# NODE
export N_PREFIX="$HOME/.n"
alias nodex='node --experimental-modules'
alias npi='npm install'
alias npid='npm install --save-dev'
alias npu='npm uninstall'
alias y=yarn

# JEKYLL
alias jek='bundle exec jekyll'
alias jeks='jek serve'
alias jeksi='jek serve --incremental'
alias jeksnow='jek serve --skip-initial-build'

# ELEVENTY
alias elv='npx @11ty/eleventy'
alias elvs='elv --serve --watch'

# REDWOOD
alias rw='yarn redwood'

# GO
export GOROOT=/snap/go/current
export GOPATH=$HOME/go
#export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
#export PATH=$PATH:$HOME/.local/bin # python/pip/aws

# TMUX
function shell { tmux rename-window $1; ssh -o TCPKeepAlive=no -o ServerAliveInterval=15 $1; tmux rename-window 'bash'; }
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator
alias tmc="vi $HOME/.tmux.conf"
alias stmc="tmux source-file ~/.tmux.conf"

alias tx=tmux
alias tm=tmuxinator
alias tma='tmux attach'
function killtmux { tmux ls | awk '{print $1}' | sed 's/://g' | xargs -I{} tmux kill-session -t {} ; }
function tmuxsurvivor { tmux detach -a ; } # kill other tmuxes, needed to expand to fit resized window
# http://www.bendangelo.me/linux/2015/10/15/remap-caps-lock-in-ubuntu.html

# SSH/MOSH
# https://stackoverflow.com/a/39445896/18706
function killmoshes { pgrep mosh-server | grep -v $(ps -o ppid --no-headers $$) | xargs kill ; }

# GIT
#export GITAWAREPROMPT=$DOTFILES/projects/git-aware-prompt
#source $DOTFILES/projects/git-aware-prompt/main.sh
if [ -f "$DOTFILES/.git-completion.txt" ] ; then
  source $DOTFILES/bin/git-completion.bash
  #__git_complete co _git_checkout
  #__git_complete merge _git_merge
fi
alias g='git'
alias gco='git checkout'
alias gcopr='hub pr checkout'
alias gbr='git branch'
alias gchanged='git diff --name-only HEAD'
alias ghard='git reset --hard HEAD'
alias gmerge='git merge'
alias gmerged='git branch --merged'
alias gnomerged='git branch --no-merged'
GITS='add bisect branch checko clone commit diff fetch grep init log merge mv pull push rebase reset rm show status tag'
if [ -f "$DOTFILES/.git-commands.txt" ] ; then
  for cmd in `cat $DOTFILES/.git-commands.txt` ; do
    alias "g$cmd"="git $cmd"
    #__git_complete $cmd _git_$cmd
  done
fi
alias gca='git commit -a'
function gc { git commit -a --message="$*" ; }
alias gd='git diff'
alias gdm='git diff master...'
alias gl='git log'
alias gnomerge='git merge --no-commit --no-ff'
function gpall  { git add . ;  git commit -m "$*" ; git push; }

# JOB CONTROL
trap_with_arg() { # from http://stackoverflow.com/a/2183063/804678
  local func="$1"; shift
  for sig in "$@"; do
    trap "$func $sig" "$sig"
  done
}

function handle_sigint() {
  for proc in `jobs -p` ; do kill $proc ; done
}

# search for jobs
function pss { ps aux | grep $1 | grep -v grep ; }

# NETWORKING
alias hos='sudo vi "+normal G" /etc/hosts'
alias resolv='sudo vi /etc/resolv.conf'

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

alias glow='glow -s light'

# POCKET
function pocketadd {
  for url in $@; do
    echo "Adding $url"
    pocket-cli add --url $1;
  done
}
alias padd=pocketadd

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

### DOCKER
alias startdocker='sudo snap start docker' # https://askubuntu.com/a/978012/40428
alias dc='docker-compose'
function dcup { dc up $*; }
function dcdown { dc down $*; }
function dcstart { dc start $*; }
function dcstop { dc stop $*; }
function dcb { dc build $*; }
function dcbn { dc build --no-cache $*; }
function dcrestart { dc restart $*; }
function dcps { dc ps $*; }
function dcup { dc up $*; }
function dcr { dc run $*; }
function dcre { dc restart $*; }
function dcbash { dc exec --privileged $* bash; } # "ssh" into it
function dchardup { dc kill; dc rm -f; dc up --force-recreate --build $*; }
function dcreset { dc rm -vf; dc up; }
function dcblast { docker stop $(docker ps -a -q); docker rm $(docker ps -a -q); docker rmi $(docker images -q) --force; docker ps ; docker images; }

function dclogs { docker-compose logs -t -f --tail=all; }
function dcresetlogs { sudo sh -c "truncate -s 0 /var/lib/docker/containers/*/*-json.log"; }
function dcl { dcresetlogs; dclogs ; }

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
  echo "set @width=$display_width; select ID, USER, HOST, DB, COMMAND, TIME, STATE, concat(substr(INFO,1,@width),IF(LENGTH(INFO) > @width, ' ...', '')) as QUERY from INFORMATION_SCHEMA.PROCESSLIST where time > $min_time AND command <> 'Sleep' ORDER by time;" | mysql | grep $filter
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

### DNS

function flushdns { sudo /etc/init.d/nscd restart; }
alias ns='nslookup'

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

### APT

function aptfree {
  sudo rm /var/lib/dpkg/lock /var/lib/dpkg/lock-frontend;
}

# https://askubuntu.com/questions/646884/how-can-i-remove-all-ppa
# dry run of purging
function listppas {
  find /etc/apt/sources.list.d -type f -name "*.list" -print0 | while read -d $'\0' file; do
    awk -F/ '/deb / && /ppa\.launchpad\.net/ {print "sudo ppa-purge ppa:"$4"/"$5}' "$file"
  done
}

### PASSWORDS

function hardpass {
  message="$@"
  length=$(( 28 + RANDOM % 16 ))
  if [ "$message" != "" ]; then
    echo "### $message"
  fi
  pwgen -1 -y -s $length
}

### APT
function apti { sudo apt install $@; }
function aptrm { sudo apt remove $@; }

### LAUNCHERS
alias rof='rofi -combi-modi window,drun,ssh -theme solarized -font "hack 32" -show combi'

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

# make native, e.g. nativefier https://tweetdeck.com
function native { nativefier -p linux -a x64 "$1" --tray; }

# toggle caps on/off - can be stuck on due to tmux config
function caps { xdotool key Caps_Lock; }
alias CAPS=caps
# force off no matter current state
function nocaps {
  state=$(xset q | grep 'Caps Lock'|awk '{print $4}')
  if [ "$state" != "off" ] ; then caps ; fi
}
alias NOCAPS=nocaps

# Caps lock for tmux
# https://unix.stackexchange.com/a/241659/36161
#setxkbmap -layout us -option ctrl:nocaps
#xmodmap -e 'clear Lock'
#xmodmap -e 'keycode 0x7e = Control_R'
#xmodmap -e 'add Control = Control_R'

### OSX
if [ "$(uname)" == "Darwin" ]; then
  export BASH_SILENCE_DEPRECATION_WARNING=1
  function iphonebackupdisable { defaults write com.apple.iTunes DeviceBackupsDisabled -bool true ; }
  function iphonebackupenable  { defaults write com.apple.iTunes DeviceBackupsDisabled -bool false ; }
  function startmysql { launchctl load ~/Library/LaunchAgents/com.mysql.mysqld.plist; }
  function stopmysql { launchctl unload ~/Library/LaunchAgents/com.mysql.mysqld.plist; }
  function flushdns { sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder; }
fi

### HOMEBREW
export HOMEBREW_CELLAR='/usr/local/Cellar'
alias bru='arch -arm64 brew' # run brew under rosetta (goes in /opt/homebrew folder). note terminal app should have "run under rosetta" checked under file properties
alias brui='bru install'

### AUDIO

# https://gist.github.com/kentbye/3843248
# txt2mp3 url <words-per-minute>
# Macos function relies on "say" and ffmpeg
# Converts to an audio file at <words-per-minute>. I personally select the UK's Serena as the Mac default voice 
function txt2mp3 {
	#FULLFILE=$1;
	#FILE="${FULLFILE%%.*}";
	FILE=$1
  VOICE='lee' # try say -v'?' for full list of voices
	# WPM=${2:-180}
	echo "converting $FILE.txt to $FILE.aiff";
	#`say -f $FILE -r 310 -o $FILE.aiff --progress`;
  rm $FILE.aiff $FILE.mp3
	`say -v $VOICE -f $FILE -o $FILE.aiff --progress`;
	echo "conververting $FILE.aiff to $FILE.mp3";
	`ffmpeg -i $FILE.aiff $FILE.mp3`;
	# Change the MP3 ID3 for the Album
	#id3tag -A$FILE $FILE.mp3;
	`rm $FILE.aiff`;
}

# https://gist.github.com/kentbye/3843248
# Macos function relies on "say" and ffmpeg
function web2mp3 {
	URL=$1
	TEXTFILE=webmp3.$$.txt
	trafilatura -u $URL > $TEXTFILE
	txt2mp3 $TEXTFILE
}

##############################################################################
### PATH ###
##############################################################################

#$HOME/.rubies/ruby-2.6.5/bin:\

PATH=''

if [ "$(/usr/bin/uname)" == "Darwin" ]; then
  echo "Setting Darwin Path"
  PATH+="\
/opt/homebrew/bin:\
$HOME/.n/bin:\
/opt/homebrew/opt/openjdk/bin:\
/opt/homebrew/opt/python/libexec/bin"
else # ubuntu
  echo "Setting Ubuntu Path"
  PATH+="\
/usr/games:\
/usr/local/games:\
/snap/bin"
fi

echo "Appending General Path"
export PATH+=":\
$HOME/bin:\
$HOME/.local/bin:\
$HOME/.n/bin:\
#$HOME/.rvm/gems/ruby-3.0.2/bin:\
$HOME/dotfiles/bin:\
/usr/local/sbin:\
/usr/local/bin:\
/usr/sbin:\
/usr/bin:\
/sbin:\
/bin:\
~/.local/bin/:$HOME/.fzf/bin:\
/usr/lib/go/bin:\
$HOME/go/bin:\
$HOME/.local/bin"
#$HOME/bin/gyb"

# RVM (run after path)
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

#export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/opt/openjdk/bin:$PATH:/opt/homebrew/bin:$HOME/.n/bin:$HOME/.npm/bin:$HOME/.rubies/ruby-2.6.5/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/bin:$HOME/dotfiles/bin:~/.local/bin/:$HOME/.fzf/bin:/usr/lib/go/bin:$HOME/go/bin:$HOME/.local/bin:$HOME/bin/gyb:$GRADLE_HOME/bin"

##############################################################################
### FINALISE TMUX ###
##############################################################################

# source this last to avoid weird xmodmap message
# https://forums.fedoraforum.org/showthread.php?296298-xmodmap-please-release-the-following-keys-within-2-seconds
if [[ -n "$TMUX" ]] ; then
  source $HOME/dotfiles/bash_tmux
  #tmux display-message -p "Welcome to tmux. Prefix key is: #{prefix}"
fi

### LOCAL MACHINE - AFTER
if [ -f $HOME/dotfiles/bash_after ] ; then
  source $HOME/dotfiles/bash_after
fi
. "$HOME/.cargo/env"
