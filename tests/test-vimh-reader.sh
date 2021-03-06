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

self_name='test-vimh-reader'
self_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

test_script="$self_dir/../vimh-reader.sh"
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
#	}}}

path_testdir='/tmp/test-vimh-reader'

files_create=( "abc.txt" "def.txt" "hij.txt" "zxy.txt" "lmn.txt" )
files_prohbit=( "abc.t" "def.t" )

echo source "$test_script" > /dev/stderr
source "$test_script"
flag_debug_vimh=1


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

	echo "$func_name, DONE"
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
	expected_str=\
"/tmp/test-vimh-reader/def.txt
/tmp/test-vimh-reader/hij.txt
/tmp/test-vimh-reader/lmn.txt
/tmp/test-vimh-reader/abc.txt
/tmp/test-vimh-reader/zxy.txt"
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: 1\n"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi

	#	Test with filter str
	result_str=$( _Vimh_get_uniquepaths "$test_data_path" "abc" )
	expected_str=\
"/tmp/test-vimh-reader/abc.txt"
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: 2\n"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi

	#	Test with test files deleted 
	delete_test_files_in_tmp
	result_str=$( _Vimh_get_uniquepaths "$test_data_path" )
	expected_str=\
""
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: 1\n"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	setup_tmp_dir_with_files

	echo "$func_name, DONE"
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
	local test_str=""
	local expected_str=""
	local result_str=""

	#	Basic test -> files in-order
	#	test_str includes leading and trailing newlines
	test_str=$nl$( create_test_str_files_list )$nl
	expected_str=\
"/tmp/test-vimh-reader/abc.txt
/tmp/test-vimh-reader/def.txt
/tmp/test-vimh-reader/hij.txt
/tmp/test-vimh-reader/zxy.txt
/tmp/test-vimh-reader/lmn.txt"
	result_str=$( _Vimh_filter_existing_paths "$test_str" )
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: 1\n"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi

	#	Test empty input -> empty output 
	test_str=""
	expected_str=\
""
	result_str=$( _Vimh_filter_existing_paths "$test_str" )
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: 2\n"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi

	#	Test with all files deleted -> empty output
	#	test_str includes leading and trailing newlines
	delete_test_files_in_tmp
	test_str=$nl$( create_test_str_files_list )$nl
	expected_str=\
""
	result_str=$( _Vimh_filter_existing_paths "$test_str" )
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: 1\n"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	setup_tmp_dir_with_files
	
	echo "$func_name, DONE"
}

test_Vimh_filter_only_dirs() {
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
	local test_str=""
	local expected_str=""
	local result_str=""

	test_str=$nl$( _Vimh_get_uniquepaths "$test_data_path" )$nl
	result_str=$( _Vimh_filter_only_dirs "$test_str" )
	expected_str=\
"/tmp/test-vimh-reader"
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: 1\n"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi

	#	Test empty input -> empty output
	test_str=""
	result_str=$( _Vimh_filter_only_dirs "$test_str" )
	expected_str=\
""
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: 2\n"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi

	echo "$func_name, DONE"
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

	echo "$func_name, DONE"
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

	echo "$func_name, DONE"
}


setup_tmp_dir_with_files() {
#	{{{
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
	#echo mkdir "$path_testdir" > /dev/stderr
	mkdir -p "$path_testdir"
	if [[ ! -d "$path_testdir" ]]; then
		echo "$func_name, error, not found, path_testdir=($path_testdir)" > /dev/stderr
		exit 2
	fi
	for f in "${files_create[@]}"; do
		local path_create="$path_testdir/$f"
		#echo touch "$path_create" > /dev/stderr
		touch "$path_create"
		if [[ ! -f "$path_create" ]]; then echo "$func_name, error, not created, path_create=($path_create)" > /dev/stderr; exit 2; fi
	done
	for f in "${files_prohbit[@]}"; do
		local path_prohibit="$path_testdir/$f"
		if [[ -e "$path_prohibit"  ]]; then echo "$func_name, error, '$path_prohibit' exists (test requires that it does not)" > /dev/stderr; exit 2; fi
	done
}
#	}}}

delete_test_files_in_tmp() {
#	{{{
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
	for f in "${files_create[@]}"; do
		local path_delete="$path_testdir/$f"
		#echo rm "$path_delete" > /dev/stderr
		rm "$path_delete"
		if [[ -f "$path_delete" ]]; then echo "$func_name, error, not deleted, path_delete=($path_delete)" > /dev/stderr; exit 2; fi
	done
}
#	}}}

create_test_str_files_list() {
#	{{{
	local test_str=""
	for f in "${files_create[@]}"; do
		local path_file="$path_testdir/$f"
		test_str="$test_str$path_file$nl"
	done
	for f in "${files_prohbit[@]}"; do
		local path_file="$path_testdir/$f"
		test_str="$test_str$path_file$nl"
	done
	echo "$test_str"
}
#	}}}


setup_tmp_dir_with_files

test_Vimh_read_paths_in_file
test_Vimh_get_uniquepaths
test_Vimh_filter_existing_paths
test_Vimh_filter_only_dirs

#	UNIMPLEMENTED
#test_Vimh_truncate_paths_to_screen
#test_Vimh_prompt_open_files


echo "DONE" > /dev/stderr

