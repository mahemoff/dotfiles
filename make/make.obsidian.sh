#!/bin/bash
#
# MOTIVIATION
# Obsidian syncs config files between devices if you have the sync plugin, but
# there's no support for syncing config files *between* vaults. One approach
# would be to sync them with symlinks, but this is OS-specific and can't be
# achieved on iPad etc, so I'd rather keep a canonical version and copy them
# across to all vaults.
if [ "$OBSIDIAN_VAULT_ROOT" != "" ]; then
  echo 'syncing obsidian vaults'
  cd $OBSIDIAN_VAULT_ROOT
  for vault in $(find . -type d -mindepth 1 -maxdepth 1); do
    echo "syncing vault $vault"
    rsync -av "$HOME/dotfiles/obsidian/every-vault/" $vault
  done
fi
