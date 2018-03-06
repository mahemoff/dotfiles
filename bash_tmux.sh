# Setup "inner" tmux settings, ie those inside a remote shell
# Default tmux prefix uses c-b so we use c-a when we detect we're in a remote tmux window
# This gets way better using Caps Lock for c-b and section key (§) for c-a ...
# Ideally, should only run this once per server instance (maybe using tmux -c after launch??)
#    maybe using if-shell 'test "$(uname)" = "Linux"' 'source ~/.tmux-linux.conf'
# See: https://gist.github.com/mahemoff/5288473
if [[ -n "$SSH_CLIENT" ]]; then
  tmux unbind c-b
  tmux set -g prefix \` > /dev/null
  tmux bind -n c-q send-keys '`'
  tmux bind c-a send-prefix        
  tmux set-window-option -g status-bg green > /dev/null
  tmux set-window-option -g status-fg black > /dev/null
  # https://gist.github.com/burke/5960455
  tmux bind C-c run "tmux save-buffer - | pbcopy-remote"
  tmux bind C-v run "tmux set-buffer $(pbpaste-remote); tmux paste-buffer"
else
  tmux set -g mouse
fi

if [[ "$(uname)" == "Darwin" ]] ; then
  xmodmap -e "keycode 66 = F12" -e 'clear Lock'
  tmux set-option -g default-command "reattach-to-user-namespace -l bash" > /dev/null
  tmux bind C-c run "tmux save-buffer - | reattach-to-user-namespace pbcopy"
  tmux bind C-v run "reattach-to-user-namespace pbpaste | tmux load-buffer - && tmux paste-buffer"
else
  tmux set-option -g prefix F12 # https://bbs.archlinux.org/viewtopic.php?id=198270
  tmux bind-key F12 last-window
fi
