#!/bin/bash
# http://blog.smalleycreative.com/tutorials/using-git-and-github-to-manage-your-dotfiles/
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

############################
# HELPER FUNCTIONS
############################

function log() {
  if [ "$DOTFILES_LOG" == 'verbose' ]; then
    echo "$*"
  fi
}

############################
# SCRIPT
############################

cd `dirname $0`

########## Variables

dir=~/dotfiles                    # dotfiles directory
backupdir=~/backup/dotfiles          # old dotfiles backup directory
files="bash_profile gitconfig vimrc tmux.conf vim inputrc editrc bash_before bash_after bash_tmux myclirc tigrc irbrc toprc"    # list of (dot)files to symlink in homedir

##########

# create dotfiles_old in homedir
log "Creating $backupdir for backup of any existing dotfiles in ~"
mkdir -p $backupdir
log "...done"

# change to the dotfiles directory
log "Changing to the $dir directory"
cd $dir
log "...done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 

for file in $files; do
  log "Moving any existing dotfiles from ~ to $backupdir"
  if [ -f "$backupdir/.$file" ] ; then rm $backupdir/.$file ; fi # suppress silly "identical file error" from mv
  mv ~/.$file $backupdir 2>/dev/null
  log "Creating symlink to $file in home directory."
  ln -sf $dir/$file ~/.$file
done
