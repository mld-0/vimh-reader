#!/usr/bin/env zsh
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
nl=$'\n'
tab=$'\t'
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes
#	{{{
#	Ongoing: 2022-06-06T18:58:54AEST test providing user input to functions?
#	Ongoing: 2022-06-06T19:43:01AEST test requires /private/tmp (also accessible as /tmp) (macOS temp dir that isn't TMPDIR)
#	2023-05-04T22:11:37AEST use mktemp to create path_testdir?
#	}}}

self_name='test-vimh-reader'
self_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

test_script="$self_dir/../vimh-reader.sh"
test_data_path="$self_dir/data/vimh.txt"
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

_vimh_flag_debug=1


##	UNIMPLEMENTED, test_Vimh_get_uniquepathCounts
#	{{{
#test_Vimh_get_uniquepathCounts() {
#	#	{{{
#	local func_name=""
#	if [[ -n "${ZSH_VERSION:-}" ]]; then 
#		func_name=${funcstack[1]:-}
#	elif [[ -n "${BASH_VERSION:-}" ]]; then
#		func_name="${FUNCNAME[0]:-}"
#	else
#		printf "%s\n" "warning, func_name unset, non zsh/bash shell" > /dev/stderr
#	fi
#	#	}}}
#	local result_str=""
#	local expected_str=""
#	result_str=$( _Vimh_get_uniquepathCounts "$test_data_path" )
#	echo "$func_name, DONE"
#}
#	}}}

main() {
	setup_tmp_dir_with_files

	#	UNIMPLEMENTED
	#test_Vimh_get_uniquepathCounts

	test_Vimh_read_paths_in_file
	test_Vimh_get_uniquepaths
	test_Vimh_only_existing_files
	test_Vimh_only_dirs
	test_Vimh_only_repo_dirs

	#	UNIMPLEMENTED
	#test_Vimh_truncate_paths_to_screen
	#test_Vimh_prompt_open_files

	echo "DONE" > /dev/stderr
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
	local i=1
	local lines_limit=$_vimh_lines_limit

	#	Test without filter_str (1)
	result_str=$( _Vimh_read_paths_in_file "$test_data_path" "" "$lines_limit" )
	expected_str=$( cat "$test_data_path" | grep --text -v "^#" | tail -n "$lines_limit" | awk -F'\t' '{print $5}' )
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	i=$( perl -E "say $i+1" )

	#	Test with filter_str (2)
	result_str=$( _Vimh_read_paths_in_file "$test_data_path" "abc" "$lines_limit" )
	expected_str=$( cat "$test_data_path" | grep --text -v "^#" | grep "abc" | tail -n "$lines_limit" | awk -F'\t' '{print $5}' )
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	i=$( perl -E "say $i+1" )

	#	Test '--limit 0' (3)
	lines_limit=0
	result_str=$( _Vimh_read_paths_in_file "$test_data_path" "abc" "$lines_limit" )
	expected_str=$( cat "$test_data_path" | grep --text -v "^#" | grep "abc" | awk -F'\t' '{print $5}' )
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	i=$( perl -E "say $i+1" )

	#	Test '--limit 1' (4)
	lines_limit=1
	result_str=$( _Vimh_read_paths_in_file "$test_data_path" "abc" "$lines_limit" )
	expected_str=$( cat "$test_data_path" | grep --text -v "^#" | grep "abc" | tail -n "$lines_limit" | awk -F'\t' '{print $5}' )
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	i=$( perl -E "say $i+1" )

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
	local i=1
	local realpath_testdir=$( readlink -f "$path_testdir" )

	#	Test without filter_str
	result_str=$( _Vimh_get_uniquepaths "$test_data_path" )
	expected_str=\
"$path_testdir/def.txt
$path_testdir/hij.txt
$path_testdir/lmn.txt
$path_testdir/abc.txt
$path_testdir/zxy.txt
$path_testdir/symdef.txt"
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	i=$( perl -E "say $i+1" )

	#	Test with filter_str
	result_str=$( _Vimh_get_uniquepaths "$test_data_path" "abc" )
	expected_str=\
"$path_testdir/abc.txt"
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi

	#	Test with '--imaginary'
	result_str=$( _Vimh_get_uniquepaths "$test_data_path" "" "--imaginary" )
	expected_str=\
"$path_testdir/def.txt
$path_testdir/hij.txt
$path_testdir/lmn.txt
$path_testdir/abc.t
$path_testdir/abc.txt
$path_testdir/zxy.txt
$path_testdir/def.t
$path_testdir/symdef.txt
$path_testdir/symabc.t"
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	i=$( perl -E "say $i+1" )

	#	Test with test files deleted 
	delete_test_files_in_tmp
	result_str=$( _Vimh_get_uniquepaths "$test_data_path" )
	expected_str=\
""
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	i=$( perl -E "say $i+1" )
	setup_tmp_dir_with_files

	result_str=$( _Vimh_get_uniquepaths "$test_data_path" "" "" "--readlink" )
	expected_str=\
"$path_testdir/hij.txt
$path_testdir/lmn.txt
$path_testdir/abc.txt
$path_testdir/zxy.txt
$path_testdir/def.txt" 
	expected_str=$( echo "$expected_str" | sed "s|$path_testdir|$realpath_testdir|g" )
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	i=$( perl -E "say $i+1" )

	result_str=$( _Vimh_get_uniquepaths "$test_data_path" "" "--imaginary" "--readlink" )
	expected_str=\
"$path_testdir/hij.txt
$path_testdir/lmn.txt
$path_testdir/abc.txt
$path_testdir/zxy.txt
$path_testdir/def.t
$path_testdir/def.txt
$path_testdir/abc.t" 
	expected_str=$( echo "$expected_str" | sed "s|$path_testdir|$realpath_testdir|g" )
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	i=$( perl -E "say $i+1" )

	echo "$func_name, DONE"
}


test_Vimh_only_existing_files() {
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
	local i=1

	#	Basic test -> files in-order
	#	test_str includes leading and trailing newlines
	test_str=$nl$( create_test_str_files_list )$nl
	expected_str=\
"$path_testdir/abc.txt
$path_testdir/def.txt
$path_testdir/hij.txt
$path_testdir/zxy.txt
$path_testdir/lmn.txt
$path_testdir/symdef.txt"
	result_str=$( _Vimh_only_existing_files "$test_str" )
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	i=$( perl -E "say $i+1" )

	#	Test empty input -> empty output 
	test_str=""
	expected_str=\
""
	result_str=$( _Vimh_only_existing_files "$test_str" )
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	i=$( perl -E "say $i+1" )

	#	Test with all files deleted -> empty output
	#	test_str includes leading and trailing newlines
	delete_test_files_in_tmp
	test_str=$nl$( create_test_str_files_list )$nl
	expected_str=\
""
	result_str=$( _Vimh_only_existing_files "$test_str" )
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	setup_tmp_dir_with_files
	i=$( perl -E "say $i+1" )

	echo "$func_name, DONE"
}

test_Vimh_only_dirs() {
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
	local i=1

	test_str=$nl$( _Vimh_get_uniquepaths "$test_data_path" )$nl
	result_str=$( _Vimh_only_dirs "$test_str" )
	expected_str=\
"$path_testdir"
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	i=$( perl -E "say $i+1" )

	#	Test empty input -> empty output
	test_str=""
	result_str=$( _Vimh_only_dirs "$test_str" )
	expected_str=\
""
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	i=$( perl -E "say $i+1" )

	echo "$func_name, DONE"
}

test_Vimh_only_repo_dirs() {
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
	local i=1

	local previous_PWD=$PWD
	cd "$path_testdir"
	if [[ -d ".git" ]]; then
		rm -r ".git"
	fi
	cd "$previous_PWD"
	test_str=$nl$( _Vimh_get_uniquepaths "$test_data_path" )$nl
	result_str=$( _Vimh_only_dirs "$test_str" )
	result_str=$( _Vimh_only_repo_dirs "$result_str" )
	expected_str=\
""
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	i=$( perl -E "say $i+1" )

	local previous_PWD=$PWD
	cd "$path_testdir"
	git init  --quiet
	test_str=$nl$( _Vimh_get_uniquepaths "$test_data_path" )$nl
	result_str=$( _Vimh_only_dirs "$test_str" )
	result_str=$( _Vimh_only_repo_dirs "$result_str" )
	rm -r ".git"
	cd "$previous_PWD"
	expected_str=\
"$path_testdir"
	if [[ ! "$result_str" == "$expected_str" ]]; then
		echo "$func_name, fail: $i\n"
		echo "$func_name, result_str=($result_str)"
		echo "$func_name, expected_str=($expected_str)"
		diff <( echo $result_str ) <( echo $expected_str )
		exit 2
	fi
	i=$( perl -E "say $i+1" )

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
	if [[ -d "$path_testdir" ]]; then
		rm -r "$path_testdir"
	fi
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
	ln -s "$path_testdir/def.txt" "$path_testdir/symdef.txt"
	ln -s "$path_testdir/abc.t" "$path_testdir/symabc.t"
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
	rm "$path_testdir/symdef.txt"
	rm "$path_testdir/symabc.t"
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
	local path_file=""
	for f in "${files_create[@]}"; do
		path_file="$path_testdir/$f"
		test_str="$test_str$path_file$nl"
	done
	for f in "${files_prohbit[@]}"; do
		path_file="$path_testdir/$f"
		test_str="$test_str$path_file$nl"
	done
	path_file="$path_testdir/symdef.txt"
	test_str="$test_str$path_file$nl"
	path_file="$path_testdir/symabc.t"
	test_str="$test_str$path_file$nl"
	echo "$test_str"
}
#	}}}



main "$@"


