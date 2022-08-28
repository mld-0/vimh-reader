#!/usr/bin/env zsh
#	{{{3
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

self_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

path_bak_vimh="$self_dir/data/bak.1661611972.vimh"
test_script="$self_dir/../vimh-reader.sh"
#	{{{
if [[ ! -f "$test_script" ]]; then
	echo "$self_name, error, not found, test_script=($test_script)" > /dev/stderr
	exit 2
fi
if [[ ! -f "$path_bak_vimh" ]]; then
	echo "$self_name, error, not found, path_bak_vimh=($path_bak_vimh)" > /dev/stderr
	exit 2
fi
#	}}}

echo source "$test_script" > /dev/stderr
source "$test_script"

#	vimh-reader is using homebrew grep 

main() {
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

	#	bug was with use of grep "$filter_str" -> only (complete) function doing this is '_Vimh_read_paths_in_file'

	local filter_str=""
	local path_tmp=`mktemp -d`

	#	lines in file: 153578 lines (correct)
	#cat "$path_bak_vimh" | wc -l

	#	use grep with an empty filter string:
	#		warning: 'grep: (standard input): binary file matches'
	#		151569 lines (incorrect) (2009 lines missing)
	#cat "$path_bak_vimh" | grep "$filter_str" | wc -l

	#	Using '-v' (trying to identify eliminated lines) not only works (result from 'wc -l' is 0), (but also terminates the scripts with an error?)
	#cat "$path_bak_vimh" | grep -v "$filter_str" | wc -l
	
	#	Examine lines that have been removed
	#cat "$path_bak_vimh" > "$path_tmp/1.txt"
	#cat "$path_bak_vimh" | grep "$filter_str" > "$path_tmp/2.txt"
	#diff "$path_tmp/1.txt" "$path_tmp/2.txt" | head -n 20

	#	Identify removed lines by line-number: 
	#cat -n "$path_bak_vimh" | awk '{print $1}' > "$path_tmp/1.txt"
	#cat -n "$path_bak_vimh" | grep "$filter_str" | awk '{print $1}' > "$path_tmp/2.txt"
	#diff "$path_tmp/1.txt" "$path_tmp/2.txt"
	#	lines removed = [151663,153578]

	#	Problem is (some combination of grep (with an empty string), and a log file with some bad data in it(?))
	#	*(what about with a non-empty filter_str?)

	#	Lesson (at this stage), 'grep ""' supposedly does nothing, but doesn't do nothing (rejects lines) for some input files

	#	Lines containing <binary/non-ascii> data
	#	<>

	#	Problem is resolved(?) by supplying grep with '--text' flag
	#cat -n "$path_bak_vimh" | awk '{print $1}' > "$path_tmp/1.txt"
	#cat -n "$path_bak_vimh" | grep --text "" | awk '{print $1}' > "$path_tmp/2.txt"
	#diff "$path_tmp/1.txt" "$path_tmp/2.txt"

	#	Suggestion: problem is caused by null bytes
	#	Are null bytes a possible cause of 'grep binary file' warning, or does 'grep binary file' warning mean there are null bytes

	#	Continue: 2022-08-28T23:18:06AEST behaviour of grep given <non-ascii/null> bytes
	#	Continue: 2022-08-28T23:18:28AEST grep, wherever used (on a file that might concievably get corrupted/null-bytes/binary-data/this-has-happened-before), it should use grep with the '--text' / '-a' flag (this fixes the problem seen <here>?)

	#	Search for null bytes in file:
	#	grep -Pa '\x00' $path_file
	#	results are '/etc/pam.d/sudo' and '/private/etc/pam.d/bak.2022-08-22.sudo' (but not quite all instances of the later?)
	#	Is the bug a result of opening vim with sudo?

	#	Search for non-ascii bytes in file:
	#	grep --color='auto' -P -n "[^\x00-\x7F]" $path_file
	#	(this doesn't identify anything?) (several other commands which identify nothing in our file)
	#	command which does:
	#	perl -ne 'print "$. $_" if m/[\x00-\x08\x0E-\x1F\x80-\xFF]/'
	#	(produces same lines as first grep command (see above))

	#	TODO: 2022-08-28T23:27:09AEST vimh, (investigation) is null byte written to log when we open file with sudo?
	#	TODO: 2022-08-28T23:27:48AEST vimh, (investigation) removing non-ascii data from text file

}

main
