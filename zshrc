[[ $0 = '-zsh' ]] && local login=${login-true}

exec 3>&1 4>&2 5>/dev/null

if [[ -n $VERBOSE || -n $DEBUG ]]; then
  exec 1>&3 2>&4
else
  exec 1>&5 2>&5
fi

local overrides_file="$HOME/.zshrc.local"
overrides-exist() {
  [[ -f $overrides_file ]]
}

overrides-exist && source $overrides_file

# Path to your oh-my-zsh installation.
export ZSH=${ZSH:-$HOME/.oh-my-zsh}
#export PAGER='less -is'
export EDITOR=vim
[[ -d ~/.tmux/tmp ]] && export TMUX_TMPDIR=${TMUX_TMPDIR:-~/.tmux/tmp}

#echo 'unsetopt:'; unsetopt | grep glob | sed -Ee 's/^/\t/'
#echo 'setopt:'; setopt | grep glob | sed -Ee 's/^/\t/'

setopt extendedglob cshnullglob numericglobsort

#echo 'unsetopt:'; unsetopt | grep glob | sed -Ee 's/^/\t/'
#echo 'setopt:'; setopt | grep glob | sed -Ee 's/^/\t/'

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="sunrise"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git rails bundler)

# User configuration

#export PATH="/opt/boxen/rbenv/shims:/opt/boxen/rbenv/bin:/opt/boxen/rbenv/plugins/ruby-build/bin:/opt/boxen/nodenv/bin:/opt/boxen/nodenv/shims:/opt/boxen/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:${HOME}/src/android-sdk/tools"

#source /opt/boxen/env.sh

#PATH="$(echo {/usr,}"/"{,s}"bin" | tr ' ' ':'):$PATH"
#PATH="/opt/boxen/homebrew/bin:$PATH"
#PATH="$(echo "/opt/boxen/"{rb,nod}"env/"{bin,shims} | tr ' ' ':'):$PATH"
#PATH="$(echo "$HOME/"{bin,src/android-sdk/tools} | tr \  :):$PATH"

eval "$(MANPATH= PATH= /usr/libexec/path_helper)"

[[ -f /opt/boxen/env.sh ]] && source /opt/boxen/env.sh

PATH="$(echo "$HOME/"{bin,src/android-sdk/{,platform-}tools} | gsed 's/ \//:\//g'):$PATH"

[[ -d $ZSH && -f $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh

if-exec-exists() {
	exec-exists $1 && $@
}

exec-exists() {
	for executable in $@; do
		which $executable || return 1
	done &>/dev/null
}

#which gulp &>/dev/null && eval "$(gulp --completion=zsh)"
exec-exists gulp && eval "$(gulp --completion=zsh)"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias ionice="~/bin/ionice"
alias -g icp="ionice cp"
alias -g idu="ionice du -chs"
alias -g ils="ionice ls"
alias -g imkdir="ionice mkdir"
alias -g imv="ionice mv"
alias -g irm="ionice rm"

alias ps-mem="ps -aem -opid,ppid,%cpu,%mem,vsz,rss,start,time,command"
alias ps-cpu="ps -aer -opid,ppid,%cpu,%mem,start,time,utime,command"

tmux-handler() {
	if [[ $# -eq 0 ]]; then
		$0 "${$(pwd):t}"
	elif [[ $# -eq 1 ]]; then
		tmux new -As $1
	elif [[ $# -eq 2 && $1 == '-d' ]]; then
		tmux new -ADs $2
	elif [[ $1 == A || $1 == D ]]; then
		local -A flags
		flags=(A 1 $1 1)
		shift
		tmux new -${(kj//)flags}s $@
	else
		tmux $@
	fi
}
alias tm='tmux-handler'
alias tmls='tmux ls'

if [[ -d /Applications/Dash.app || -d ~/Applications/Dash.app ]]; then
  alias dash='dash-helper'
fi

alias du='du -Lch'
sdu() {
	\du -Hch $@ | gsort -h
}

man() {
	local save=${MANWIDTH+1} saved_manwidth=$MANWIDTH \
		cols=$(tput cols)
	[ $cols -gt 65 -a $cols -le 69 ] && cols=65

	export MANWIDTH=$cols
	command man $@

	if [[ -n $save ]]
	then
		MANWIDTH=$saved_manwidth
	else
		unset MANWIDTH
	fi
}
#alias man='export MANWIDTH=$(tput cols); man'

iphone-transfers() {
	BLOCKSIZE=1000000 ls -afs ~dl/*(.om[1,${1:-10}])
}

for folder in {tv,dl}
do
	for action in {add,enqueue}
	do
		#echo "alias \"\${folder}-\${action}\"=\"vlc-\${action} ~\${folder}/\""
		alias -g "${folder}-${action}"="echo vlc-${action} ~${folder}/"
	done
done
#alias -g vim='vimsrv --remote-tab'
alias -g vimsrv='\vim --servername matt-main'

alias -g mrgsql="noglob mysql -S '${BOXEN_MYSQL_SOCKET}' -u root -D Margarita_development"
mrgselect() {
	mrgsql -e "select $*"
}
alias -g mrgselect='noglob mrgselect'

typeset -a emulator_options
emulator_options=(-show-kernel -no-boot-anim -cpu-delay 0 -wipe-data -debug-all)

emu-android() {
	if [ $# -eq 0 ]; then
		echo "$0 <avd> [... options]" >&2
		android list avd
		return 1
	fi
	local cmd="emulator -avd $1 ${emulator_options} $@[2,-1]"

	echo log-all -n "$HOME/logs/emulator.$1" -- $cmd
	log-all -n "$HOME/logs/emulator.$1" -- $cmd
}

emu-android-x86() {
	if [ $# -eq 0 ]; then
		echo "$0 <avd> [... options]" >&2
		android list avd
		return 1
	fi
	local cmd="emulator-x86 -avd $1 ${emulator_options} $@[2,-1]"

	echo log-all -n "$HOME/logs/emulator.$1" -- $cmd
	log-all -n "$HOME/logs/emulator.$1" -- $cmd
}

emu-android-x86_64() {
	if [ $# -eq 0 ]; then
		echo "$0 <avd> [... options]" >&2
		android list avd
		return 1
	fi
	local cmd="emulator64-x86 -avd $1 ${emulator_options} $@[2,-1]"

	echo log-all -n "$HOME/logs/emulator.$1" -- $cmd
	log-all -n "$HOME/logs/emulator.$1" -- $cmd
}

exec-exists process-aliases && eval "$(process-aliases)"

#hash -d tv='/opt/TV'
hash -d dl=/opt/DL
hash -d media=/media
hash -d tv=~media/TV
hash -d movies=~media/Movies
hash -d vm='/private/var/vm'
hash -d sleepimage=~vm/sleepimage

hash -d wally='/Volumes/WALLY WEST'
hash -d wally-west='/Volumes/WALLY WEST'
hash -d ww=~wally
hash -d kingston='/Volumes/KINGSTON'

hash -d wally-tv='/Volumes/WALLY WEST/TV'
hash -d wally-west-tv='/Volumes/WALLY WEST/TV'
hash -d ww-tv=~wally-tv
hash -d kingston-tv='/Volumes/KINGSTON/TV'

hash -d boxen='/opt/boxen'
[[ -n "$BOXEN_HOME" ]] && hash -d boxen=$BOXEN_HOME
[[ -n "$DEV_ROOT" ]] && hash -d dev=$DEV_ROOT
[[ -n "$NODENV_ROOT" ]] && hash -d nodenv=$NODENV_ROOT
[[ -n "$PYENV_ROOT" ]] && hash -d pyenv=$PYENV_ROOT
[[ -n "$RBENV_ROOT" ]] && hash -d rbenv=$RBENV_ROOT
exec-exists brew && {
  hash -d homebrew=$(brew --prefix)
  fpath=( ~homebrew/share/zsh-completions $fpath )
}

which nodenv &>/dev/null && eval "$(nodenv init -)"
which pyenv &>/dev/null && eval "$(pyenv init -)"
which rbenv &>/dev/null && eval "$(rbenv init -)"

export LESS="$LESS -iS" # was '$LESS -is', but I removed squeeze repeated blank lines

zmodload zsh/datetime zsh/stat
autoload -U read-from-minibuffer
autoload -U calendar age before after
autoload -U zcalc
#autoload -Uz {dl-magnet,vlc-control}-widget

autoload -U auto-reload
autoload -U tmux-helper
alias tm=tmux-helper

{
  local -aU user_path

  user_path=('/Users/mattspatola/bin')
  user_path=( $local_path $user_path $path $local_path_suffix )

  path=( $user_path )
  unset user_path
}

{
  local -aU user_fpath

  user_fpath=('/Users/mattspatola/share/zsh/functions')
  user_fpath=( $local_fpath $user_fpath $fpath $local_fpath_suffix )

  fpath=( $user_fpath )
  unset user_fpath
}

{
  local -aU user_manpath

  user_manpath=('/Users/mattspatola/share/man')
  user_manpath=( $local_manpath $user_manpath $manpath $local_manpath_suffix )

  manpath=( $user_manpath )
  unset user_manpath
}

new-widget() {
	zle -N "$1"
	for key in $@[2,-1]; do
		bindkey "$key" "$1"
	done
}

#new-widget vlc-control-widget	'^q'
#new-widget dl-magnet-widget	'^s'
bindkey '\ee' edit-command-line

bindkey '\e[1;9D' backward-word
bindkey '\e[1;9C' forward-word

local ZSHRC_TIME_FORMAT='%Y/%m/%d:%H:%M:%S'
current_time() {
	 strftime $ZSHRC_TIME_FORMAT $EPOCHSECONDS
}
export ZSHRC_LOADED=$(current_time)
zshrc_changed() {
	local REPLY=~/.zshrc
	age ${1-$ZSHRC_LOADED} now
}
tmux_conf_mod_time() {
	tmux show-environment TMUX_CONF_LOADED > >(cut -d= -f2-) 2>/dev/null
}
old_tmux_conf_changed() {
	local REPLY=~/.tmux.conf
	age ${1-$TMUX_CONF_LOADED} now
}
tmux_conf_changed() {
	local REPLY=~/.tmux.conf
	#echo age ${$(tmux_conf_mod_time):-2010-01-01} now
	age ${$(tmux_conf_mod_time):-2010-01-01} now
}
source-tmux() {
	tmux source-file ~/.tmux.conf
	tmux set-environment TMUX_CONF_LOADED $(current_time)
}

alias reconfig='{echo -n "reloading .zshrc . . . "; . ~/.zshrc; echo "DONE!"}; #'
tmux_reconfig() {
	local REPLY=~/.tmux.conf
	[[ -n "$TMUX" ]] &&
		age ${$(
			tmux show-environment TMUX_CONF_LOADED \
				> >(cut -d= -f2-) 2>/dev/null
		):-2010-01-01} now &&
		{ tmux source-file ~/.tmux.conf
		  tmux set-environment TMUX_CONF_LOADED $(current_time) }
}
periodic() {
	local conf_loaded
	export login=''
	zshrc_changed && reconfig
	tmux_reconfig
}
export PERIOD=10

if [[ $1 == eval ]]; then
	local zliset
	echo "Starting interactive zshi shell"
	echo 'interactive'
	shift
	ICMD=$@
	set --
	zle-line-init() {
		BUFFER="$ICMD"
		CURSOR=$#ICMD
		#zle accept-line
		zle reset-prompt
		zle -D zle-line-init
	}
	zle -N zle-line-init
	#zle-line-init() {
	#	#zle accept-line
	#	[ $zliset ] && zle -D zle-line-init && unset zliset
	#	BUFFER="$ICMD"
	#	CURSOR=$#ICMD
	#}
	#zle -N zle-line-init
	#zliset=on
elif [[ $1 = config ]]; then
	CONTENTS=$(cat ~/.zshrc)
	vim ~/.zshrc
	shift
	if diff -q ~/.zshrc - <<<"$CONTENTS">/dev/null
	then
		echo .zshrc unchanged, exiting
	else
		echo .zshrc changed, starting with new config
		exec -l zsh -l
	fi
elif [[ $1 = loc ]]; then
	shift
	shift
elif [[ $1 = tmux ]]; then
	exec tmux new -As $2
fi
#
# +-----+-----+--------+-------+--------+
# |char | (q) |  (qq)  | (qqq) | (qqqq) |
# +-----+-----+--------+-------+--------+
# |'    | \'  | ''\''' |  "'"  | $'\''  |
# +-----+-----+--------+-------+--------+
# |"    | \"  |  '"'   | "\""  |  $'"'  |
# +-----+-----+--------+-------+--------+

[[ -n $login ]] && if-exec-exists session-prompt

if overrides-exist; then
  if functions local-outro &>/dev/null; then
    local-outro
    unfunction local-outro
  else
    printf 'No `local-outro` function defined by override file %s\n' ${(qq)overrides_file}
    echo 'If defined, this file will be run at the end of .zshrc'
  fi
fi

exec 1>&3 2>&4
