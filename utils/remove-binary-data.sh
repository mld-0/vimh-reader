#!/usr/bin/env bash
#	vim-settings {{{3
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes


remove_binary_data() {
	#	{{{
	local func_name=""
	if [[ -n "${ZSH_VERSION:-}" ]]; then 
		func_name=${funcstack[1]:-}
	elif [[ -n "${BASH_VERSION:-}" ]]; then
		func_name="${FUNCNAME[0]:-}"
	else
		printf "%s\n" "warning, func_name unset, non zsh/bash shell" > /dev/stderr
	fi
	#	}}}
	local func_about="remove binary data from given file"
	local func_help="""$func_name, $func_about
    Command: tr -cd '\\11\\12\\15\\40-\\176' 

    Usage: ./remove-binary-data.sh PATH_INPUT 

	Args:
        \$1        path_in
"""
	#	print help:
	#	{{{
	if echo "${1:-}" | perl -wne '/^\s*-h|--help\s*$/ or exit 1'; then
		echo "$func_help"
		return 2
	fi
	#	}}}

	local path_in="$1"

	if [[ ! -f "$path_in" ]]; then
		echo "$func_name, error, not found \$1 path_in=($path_in)" > /dev/stderr
		exit 2
	fi

	cat "$path_in" | tr -cd '\11\12\15\40-\176' 
}

remove_binary_data "$@"

