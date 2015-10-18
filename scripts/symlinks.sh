#!/usr/bin/env zsh

[ ${DEBUG+on} ] &&
	exec 4>"${HOME}/symlinks.log" 3>&1 ||
	exec 4>&1 3>&1

vlog() {
	[ ${VERBOSE+on} ] && echo "$*"
}

output_to_log() {
	exec >&4
}

output_to_stdout() {
	exec >&3
}

local base without_home source_prefix

base=$0:A:h:h
without_home="${base##${HOME}/}"

if [[ "${without_home}" != "${base}" ]]; then
	source_prefix="${without_home}"
else
	source_prefix="${base}"
fi

echo "Source prefix: ${source_prefix}"

output_to_log

failure_message() {
	exec 5>&1
	output_to_stdout
	echo "Failed to create link to '${1}'. Please create it with:"
	echo "    ${2}"
	exec >&5
}

link() {
	output_to_log
	local source="${source_prefix}"/"${1}" target="${HOME}"/"${2}"

	vlog "Creating symlink to ${source} at ${target}"

	link_cmd=( ln -s $source $target )

	if [ -e "${target}" ]
	then
		vlog "  ${target} already exists . . ."

		if [ -L "${target}" ]
		then
			vlog "  . . . but it's a symlink!"
			if [[ $(readlink "${target}") = "${source}" ]]
			then
				vlog "  . . . pointing to the right file!"
			else
				failure_message "${source}" "${target}"
				vlog "  . . . pointing to the wrong file!"
			fi
		fi

		return
	fi
	$link_cmd
}

output_to_stdout

#local excluded="  scripts  README.md  LICENSE  "
local -a excluded
excluded=( scripts README.md LICENSE )

echo "${base}" >&3
for node in "${base}"/*
do
	local entry="${node##${base}/}"
	[[ -z $excluded[(r)$entry] ]] && link $entry .$entry
done

#link vim .vim
link vim/vimrc .vimrc

# vim: set ts=4 sw=4 tw=0 noet ft=zsh :
