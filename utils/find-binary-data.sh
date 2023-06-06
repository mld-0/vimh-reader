#!/usr/bin/env bash
#	vim-settings {{{3
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

replace_binary_data() {
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
	local func_about="locate binary (non-printable) characters in file"
	local func_help="""$func_name, $func_about
    Commands: 
        grep --text -n '[^[:print:][:space:]]' 
        perl -pe 's/([\\\\x00-\\\\x08\\\\x0B-\\\\x0C\\\\x0E-\\\\x1F\\\\x7F-\\\\xFF])/sprintf("\\\\\\\\0x%02X",ord(\$1))/ge'

    Usage: ./find-binary-data.sh PATH_INPUT [args]

    Args:
        \$1                 path_in
        -s|--show          substitue non-printable characters for \\\\0x%X
	"""
	#	print help:
	#	{{{
	if echo "${1:-}" | perl -wne '/^\s*-h|--help\s*$/ or exit 1'; then
		echo "$func_help"
		return 2
	fi
	#	}}}

	local path_in="$1"
	local arg_show=""

	#	process args "$@"
	#	{{{
	while [[ $# -gt 0 ]]; do
		case $1 in
			-h|--help)
				echo "$func_help"
				return 2
				shift
				;;
			-s|--show)
				arg_show="$1"
				shift
				;;
			-*|--*)
				echo "Invalid argument '$1'" > /dev/stderr
				exit 2
				shift
				;;
			*)
				echo "Invalid argument '$1'" > /dev/stderr
				exit 2
				shift
				;;
		esac
	done
	#	}}}

	if [[ ! -f "$path_in" ]]; then
		echo "$func_name, error, not found \$1 path_in=($path_in)" > /dev/stderr
		exit 2
	fi

	if [[ -z "$arg_show" ]]; then
		grep --text -n '[^[:print:][:space:]]' "$path_in" 
	else
		grep --text -n '[^[:print:][:space:]]' "$path_in" | perl -pe 's/([\x00-\x08\x0B-\x0C\x0E-\x1F\x7F-\xFF])/sprintf("\\0x%02X",ord($1))/ge'
	fi
}

replace_binary_data "$@"

