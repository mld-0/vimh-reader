#!/usr/bin/env bash
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
nl=$'\n'
tab=$'\t'
#set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

flag_debug=1
log_debug() {
	#	{{{
	if [[ $flag_debug -ne 0 ]]; then
		echo "$@" > /dev/stderr
	fi
}
#	}}}


remove_binary_chars() {
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
	local func_about="about"
	local func_help="""$func_name, $func_about
	-v | --debug
	-h | --help"""
	#	{{{
	if echo "${1:-}" | perl -wne '/^\s*-h|--help\s*$/ or exit 1'; then
		echo "$func_help"
		return 2
	fi
	#	}}}
	#	parse args "$@"
	#	{{{
	for arg in "$@"; do
		case $arg in
			-h|--help)
				echo "$func_help"
				return 2
				shift
				;;
			-v|--debug)
				flag_debug=1
				shift
				;;
		esac
	done
	#	}}}
	
	local path_in="${1:-}"
	local path_out="${2:-}"

	#	validate: path_in, path_out
	#	{{{
	if [[ ! -d "$path_in" ]]; then
		echo "$func_name, error, not found path_in=($path_in)" > /dev/stderr
		exit 2
	fi
	if [[ -z "$path_out" ]]; then
		echo "$func_name, error, path_out=($path_out)" > /dev/stderr
		exit 2
	fi
	#	}}}

	#	LINK: https://alvinalexander.com/blog/post/linux-unix/how-remove-non-printable-ascii-characters-file-unix/
	echo tr -cd '\11\12\15\40-\176' < "$path_in" > "$path_out"
	tr -cd '\11\12\15\40-\176' < "$path_in" > "$path_out"
}

check_sourced=1
#	{{{
if [[ -n "${ZSH_VERSION:-}" ]]; then 
	if [[ ! -n ${(M)zsh_eval_context:#file} ]]; then
		check_sourced=0
	fi
elif [[ -n "${BASH_VERSION:-}" ]]; then
	(return 0 2>/dev/null) && check_sourced=1 || check_sourced=0
else
	echo "error, check_sourced, non-zsh/bash" > /dev/stderr
	exit 2
fi
#	}}}
if [[ "$check_sourced" -eq 0 ]]; then
	remove_binary_chars "$@"
fi


