#!/bin/bash
# http://blog.smalleycreative.com/tutorials/using-git-and-github-to-manage-your-dotfiles/
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/dotfiles                    # dotfiles directory
backupdir=~/dotfiles_backup          # old dotfiles backup directory
files="bash_profile vimrc"    # list of files/folders to symlink in homedir

##########

# create dotfiles_old in homedir
echo "Creating $backupdir for backup of any existing dotfiles in ~"
mkdir -p $backupdir
echo "...done"

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
for file in $files; do
  echo "Moving any existing dotfiles from ~ to $backupdir"
  mv ~/.$file $backupdir
  echo "Creating symlink to $file in home directory."
  ln -s $dir/$file ~/.$file
done
