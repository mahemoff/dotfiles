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

# Setup the mapping from Caps-Lock to ctrl-a, needed for tmux on MacOS
# To use this on MacOs:
# * Install Karabiner and open Karabiner-Elements
# * In "Complex Modification" section, hit "Add rule"
# * Choose "Caps Lock to Ctrl a" (it should appear if the file created below is present)
# That's it! bash_tmux should automatically be mapping this to tmux prefix
function setup_karabiner {
  if [ "$(uname)" == "Darwin" ]; then
    mkdir -p $HOME/.config/karabiner/assets/complex_modifications
    cat << END > $HOME/.config/karabiner/assets/complex_modifications/caps_lock_to_ctrl_a.json
{
  "title": "Caps Lock to Ctrl-a",
  "rules": [
    {
      "description": "Change caps_lock to ctrl-a",
      "manipulators": [
        {
          "type": "basic",
          "from": {
            "key_code": "caps_lock",
            "modifiers": {
              "optional": ["any"]
            }
          },
          "to": [
            {
              "key_code": "a",
              "modifiers": ["left_control"]
            }
          ]
        }
      ]
    }
  ]
}
END
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

# app-specific configs
setup_karabiner
