#!/bin/bash

exec 4>"${HOME}/symlinks.log" 3>&1

function output_to_log() {
	exec >&4
}

function output_to_stdout() {
	exec >&3
}

SCRIPT="$(grealpath "$0")"
BASE="$(dirname "$(dirname "$(grealpath "$0")")")"
WITHOUT_HOME="${BASE##${HOME}/}"

if [[ "${WITHOUT_HOME}" != "${BASE}" ]]
then
	SOURCE_PREFIX="${WITHOUT_HOME}"
else
	SOURCE_PREFIX="${BASE}"
fi

echo "Source prefix: ${SOURCE_PREFIX}"

output_to_log

function failure_message() {
	exec 5>&1
	output_to_stdout
	echo "Failed to create link to '${1}'. Please create it with:"
	echo "    ${2}"
	exec >&5
}

function link() {
	output_to_log
	SOURCE="${SOURCE_PREFIX}"/"${1}"
	TARGET="${HOME}"/"${2}"

	echo "Creating symlink to ${SOURCE} at ${TARGET}"

	LINK_CMD="ln -s \"${SOURCE}\" \"${TARGET}\""

	if [ -e "${TARGET}" ]
	then
		echo "  ${TARGET} already exists . . ."

		if [ -L "${TARGET}" ]
		then
			echo "  . . . but it's a symlink!"
			if [ $(readlink "${TARGET}") == "${SOURCE}" ]
			then
				echo "  . . . pointing to the right file!"
			else
				failure_message "${SOURCE}" "${TARGET}"
				echo "  . . . pointing to the wrong file!"
			fi
		fi

		return
	fi
	bash -c "${LINK_CMD}"
}

output_to_stdout

EXCLUDED="  scripts  README.md  LICENSE  "

echo "${BASE}" >&3
for path in "${BASE}"/*
do
	entry="${path##${BASE}/}"
	if [ "$entry" != "$path" ]
	then
		padded=" ${entry} "
		trimmed="${EXCLUDED/  ${entry}  /}"
		if [[ "$trimmed" == "${EXCLUDED}" ]]
		then
			link "$entry" '.'"$entry"
		fi
	fi
done

#link vim .vim
link vim/vimrc .vimrc
