#!/usr/bin/env zsh
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
nl=$'\n'
tab=$'\t'
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes
#	Ongoings:
#	{{{
#	Ongoing: 2022-06-06T18:58:54AEST test providing user input to functions?
#	Ongoing: 2022-06-06T19:43:01AEST test requires /private/tmp (also accessible as /tmp) (macOS temp dir that isn't TMPDIR)
#	}}}

self_name="test-vimh-reader"
self_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

test_script="$self_dir/../vimh-reader.sh"
test_dir_path="/tmp/test_vimh_reader"
test_data_path="$self_dir/data/vimh"
#	{{{
if [[ ! -f "$test_script" ]]; then
	echo "$self_name, error, not found, test_script=($test_script)" > /dev/stderr
	exit 2
fi
if [[ ! -f "$test_data_path" ]]; then
	echo "$self_name, error, not found, test_data_path=($test_data_path)" > /dev/stderr
	exit 2
fi
if [[ -d "$test_dir_path" ]]; then
	echo rm -r "$test_dir_path" > /dev/stderr
	rm -r "$test_dir_path"
fi
#	}}}

echo mkdir -p "$test_dir_path" > /dev/stderr
mkdir -p "$test_dir_path"

echo source "$test_script" > /dev/stderr
source "$test_script"

setup_tmp_files() {
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
	local dir_private_tmp="/private/tmp"
	if [[ ! -d "$dir_private_tmp" ]]; then
		echo "$func_name, error, not found, dir_private_tmp=($dir_private_tmp)" > /dev/stderr
		exit 2
	fi

	local files_create=( "abc.txt" "def.txt" "hij.txt" "xyz.txt" )
	local path_create=""
	for f in "${files_create[@]}"; do
		path_create="$dir_private_tmp/$f"
		touch "$path_create"
		if [[ ! -f "$path_create" ]]; then
			echo "$func_name, error, not created, path_create=($path_create)" > /dev/stderr
			exit 2
		fi
	done

	if [[ -e "/private/tmp/abc.t"  ]]; then
		echo "$func_name, error, '/private/tmp/abc.t' exists (test requires that it does not)" > /dev/stderr
		exit 2
	fi
}


test_Vimh_read_paths_in_file() {
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
	local result_str=""
	local expected_str=""

	#	Test without filter string
	result_str=$( _Vimh_read_paths_in_file "$test_data_path" )
	expected_str=$( cat "$test_data_path" | tail -n "$_vimh_lines_limit" | awk -F'\t' '{print $5}' )
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: 1\n"
		exit 2
	fi

	#	Test with filter string
	result_str=$( _Vimh_read_paths_in_file "$test_data_path" "abc" )
	expected_str=$( cat "$test_data_path" | grep "abc" | tail -n "$_vimh_lines_limit" | awk -F'\t' '{print $5}' )
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: 2\n"
		exit 2
	fi
}

test_Vimh_get_uniquepaths() {
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
	local result_str=""
	local expected_str=""

	#	Test without filter str
	result_str=$( _Vimh_get_uniquepaths "$test_data_path" )
	expected_str="/private/tmp/def.txt$nl/private/tmp/hij.txt$nl/private/tmp/lmn.txt$nl/tmp/abc.txt$nl/private/tmp/abc.txt$nl/private/tmp/zxy.txt"
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: 1\n"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi

	#	Test with filter str
	result_str=$( _Vimh_get_uniquepaths "$test_data_path" "abc" )
	expected_str="/tmp/abc.txt$nl/private/tmp/abc.txt"
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: 1\n"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
}

test_Vimh_filter_existing_paths() {
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
}

test_Vimh_truncate_paths_to_screen() {
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
}

test_Vimh_prompt_open_files() {
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
}


test_Vimh_read_paths_in_file
test_Vimh_get_uniquepaths

test_Vimh_filter_existing_paths
test_Vimh_truncate_paths_to_screen
test_Vimh_prompt_open_files

echo "DONE" > /dev/stderr

