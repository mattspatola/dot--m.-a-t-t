#!/usr/bin/env zsh

set -ex
#set -x

#export #| grep -i remote || true

local -i now="$(date +%s)" creation_time="$2"
local session="$1" host="$(hostname)" full_host="$(hostname -s)"
#local now creation_time session host full_host

#echo $((now - creation_time))

[[ -f ~/.tmux/local/session-init.zsh ]] && . ~/.tmux/local/session-init.zsh

if [[ $session =~ '^ssh-(.*)' ]]; then
  local remote_session=${REMOTE_TMUX_SESSION:-remote-tmux}
  #tmux set default-command "ssh -t $match[1] tmux new -As '$remote_session'"
  #echo tmux set default-command "ssh -t $match[1] remote-tmux '$remote_session'"
  tmux set default-command "ssh -t $match[1] '~/bin/remote-tmux' '$remote_session'"
  tmux source ~/.tmux/ssh.conf
fi

exit 0
