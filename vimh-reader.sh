#!/usr/bin/env zsh
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
nl=$'\n'
tab=$'\t'
#	{{{
#set -o errexit   # abort on nonzero exitstatus
#set -o nounset   # abort on unbound variable
#set -o pipefail  # don't hide errors within pipes
#	}}}
#	Ongoings:
#	{{{
#	Ongoing: 2022-06-05T21:16:13AEST (how to) hide bash functions (that aren't 'Vimh') from global scope (wider shell env)
#	Ongoing: 2022-06-05T21:16:55AEST (how to) turn sh-safety on then off (or as it was) again
#	Ongoing: 2022-06-05T21:31:46AEST (what would be ideal is) 'local' sh-safety settings
#	Ongoing: 2022-06-06T01:07:26AEST (how hard would it be to) tab through options (instead of typing a number?)
#	Ongoing: 2022-06-06T01:20:42AEST could we do all/part of this in (script to be executed) (only need subshell to cd to result - implies need for handler function which recieves/does transfer to dir, last thing before (then) opening said file) <- ('_Vimh_get_uniquepaths' doesn't need to be sourced?) (could we do the same thing faster in C++?)
#	Ongoing: 2022-06-06T01:23:39AEST ';' after command with redirection to /dev/[stderr|null]?
#	Ongoing: 2022-06-06T02:52:22AEST for 'cd' to work, none of the function calls leading to it can be in subshells (and we would have to use temp files (or global vars, or other dubious methods) if we wanted to return data from them) [...] (is that we find we were not doing so even before considering this possible problem indiciative of <good> design (vis-a-vis dataflow)?) 
#	Ongoing: 2022-06-06T03:07:33AEST (don't put any '|' in $HOME)
#	Ongoing: 2022-07-18T21:28:33AEST slow *and* NOT IMPLEMENTED? '_vimh_flag_only_realpaths'
#	}}}

_vimh_flag_debug=1
log_debug_vimh() { if [[ $_vimh_flag_debug -ne 0 ]]; then echo "$@" > /dev/stderr; fi }

_vimh_version="0.1"

#	local history file
_vimh_path_localhistory="$HOME/.vimh"

#	global history 
_vimh_path_dir_globalhistory="$mld_out_cloud_shared/combined-logs"
_vimh_name_globalhistory="vimh.vi.txt"

#	NOT IMPLEMENTED (slow) convert every path to realpath
_vimh_flag_only_realpaths=0		

#	application to open files
_vimh_editor="$EDITOR"

#	number of lines to given number of lines
_vimh_lines_limit=50000
#_vimh_lines_limit=0


#	validate: _vimh_path_localhistory, _vimh_path_dir_globalhistory, _vimh_editor, mld_log_vimh
#	{{{
if [[ ! -f "$_vimh_path_localhistory" ]]; then
	echo "vimh, warning, not found, _vimh_path_localhistory=($_vimh_path_localhistory)" > /dev/stderr
fi
if [[ ! -d "$_vimh_path_dir_globalhistory" ]]; then
	echo "vimh, warning, dir not found, _vimh_path_dir_globalhistory=($_vimh_path_dir_globalhistory)" > /dev/stderr
fi
if [[ ! -x "$_vimh_editor" ]]; then
	echo "vimh, warning, exe not found, _vimh_editor=($_vimh_editor)" > /dev/stderr
fi
if [[ ! -f "$mld_log_vimh" ]]; then
	echo "vimh, warning, file not found, mld_log_vim=($mld_log_vim)" > /dev/stderr
fi
if [[ ! `readlink -f "$_vimh_path_localhistory"` == "$mld_log_vimh" ]]; then
	echo "vimh, warning, _vimh_path_localhistory=($_vimh_path_localhistory) does not link to mld_log_vimh=($mld_log_vimh)"  > /dev/stderr
fi
#	}}}


##	UNIMPLEMENTED: _Vimh_get_uniquepathCounts
#	{{{
#_Vimh_get_uniquepathCounts() {
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
#	local path_input="${1:-}"
#	local filter_str="${2:-}"
#	#	validate: path_input
#	#	{{{
#	if [[ ! -f "$path_input" ]]; then
#		echo "$func_name, error, file not found, path_input=($path_input)" > /dev/stderr
#		return 2
#	fi
#	#	}}}
#
#	#	Ongoing: 2022-08-28T01:11:40AEST this use of 'grep "$filter_str"' is problematic (for an undiscovered reason)
#	#oldest_date_included=$( cat "$path_input" | grep "$filter_str" | tail -n $_vimh_lines_limit | head -n 1 | awk -F'\t' '{print $1}' )
#	oldest_date_included=$( cat "$path_input" | tail -n $_vimh_lines_limit | head -n 1 | awk -F'\t' '{print $1}' )
#
#	log_debug_vimh "$func_name, path_input=($path_input)"
#	log_debug_vimh "$func_name, filter_str=($filter_str)"
#	log_debug_vimh "$func_name, _vimh_lines_limit=($_vimh_lines_limit)"
#	log_debug_vimh "$func_name, oldest_date_included=($oldest_date_included)" > /dev/stderr
#	local read_files_str=$( _Vimh_read_paths_in_file "$path_input" "$filter_str" )
#	#log_debug_vimh "$func_name, read_files_str=($read_files_str)" 
#	local filesWithCounts=$( echo "$read_files_str" | sort -h | uniq -c | sort -h )
#	log_debug_vimh "$func_name, filesWithCounts=($filesWithCounts)"
#	local list_counts=$( echo "$filesWithCounts" | awk '{print $1}' )
#	local list_files=$( echo "$filesWithCounts" | awk '{print $2}' )
#	log_debug_vimh "$func_name, list_counts=($list_counts)"
#	log_debug_vimh "$func_name, list_files=($list_files)"
#}
#Vimh_Counts() {
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
#}
#	}}}


Vimh() {
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
	local previous__vimh_flag_debug=$_vimh_flag_debug
	local func_help="""$func_name, $func_about
	-f | --filter	[val]	Filter input lines with value
	-g | --global			Use combined logs from 'mld_out_cloud_shared'
	-d | --dirs 			Get list of unique dirs
	-v | --debug
	-h | --help
	--version"""
	local filter_str=""
	local flag_global=0
	local flag_dirs=0

	#	parse args "$@"
	#	{{{
	if echo "${1:-}" | perl -wne '/^\s*-h|--help\s*$/ or exit 1'; then
		echo "$func_help"
		return 2
	fi
	for arg in "$@"; do
		case $arg in
			-f|--filter)
				filter_str="$2"
				#	{{{
				if [[ -z "$filter_str" ]]; then
					echo "$func_name, error, filter_str=($filter_str)" > /dev/stderr
					return 2
				fi
				#	}}}
				shift
				shift
				;;
			-g|--global)
				flag_global=1
				shift
				;;
			-d|--dirs)
				flag_dirs=1
				shift
				;;
			-h|--help)
				echo "$func_help"
				return 2
				shift
				;;
			-v|--debug)
				_vimh_flag_debug=1
				shift
				;;
			--version)
				echo "$_vimh_version"
				return 2
				shift
				;;
		esac
	done
	#	}}}

	local path_input="$_vimh_path_localhistory"
	if [[ ! $flag_global -eq 0 ]]; then
		_Vimh_Update_GlobalHistory
		path_input=$( _Vimh_GetPath_GlobalHistory )
	fi

	#	Ongoing: 2022-06-06T01:33:19AEST debug output, include time taken to run '_Vimh_get_uniquepaths'
	local unique_files=$( _Vimh_get_uniquepaths "$path_input" "$filter_str" )
	if [[ $flag_dirs -ne 0 ]]; then
		unique_files=$( _Vimh_only_dirs "$unique_files" )
	fi

	#	Ongoing: 2022-06-06T01:37:14AEST can't capture output of '_Vimh_promptAndOpen' as a subshell and also display output from it before prompting for input from it (that is, can't move call to '_Vimh_cd_and_open' out of it)
	_Vimh_promptAndOpen "$unique_files"

	_vimh_flag_debug=$previous__vimh_flag_debug
}



_Vimh_get_uniquepaths() {
#	{{{
#	Test: 2022-06-06T03:16:09AEST are _Vimh_get_uniquepaths outputs each unique?
#	Ongoing: 2022-06-06T01:18:36AEST use of 'echo' with/without '-n'  (would it change anything) (anywhere?)
#	Ongoing: 2022-06-05T21:28:54AEST would it be faster to filter for existance before filtering for uniqueness? [...] new vimh is somehow slower than old one?
#	}}}
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
	local path_input="${1:-}"
	local filter_str="${2:-}"
	#	validate: path_input
	#	{{{
	if [[ ! -f "$path_input" ]]; then
		echo "$func_name, error, file not found, path_input=($path_input)" > /dev/stderr
		return 2
	fi
	#	}}}
	if [[ $_vimh_flag_only_realpaths -ne 0 ]]; then
		echo "$func_name, error, _Vimh_filter_realpaths not available" > /dev/stderr
		return 2
		#files_list_str=$( _Vimh_filter_realpaths "$files_list_str" | tac | awk '!count[$0]++' | tac )
	fi

	local read_files_str=$( _Vimh_read_paths_in_file "$path_input" "$filter_str" )
	#	Ongoing: 2022-08-28T00:59:19AEST result is incorrect(?)
	#log_debug_vimh "$func_name, read_files_str=($read_files_str)"

	local files_list_str=$( echo "$read_files_str" | tac | awk '!count[$0]++' | tac )

	#	validate non-empty: files_list_str
	#	{{{
	if [[ -z "$files_list_str" ]]; then
		echo "$func_name, error, files_list_str=($files_list_str)" > /dev/stderr
		return 2
	fi
	#	}}}

	#	Ongoing: 2022-08-28T00:57:48AEST disabled as we investigate the 'broken' problem
	#files_list_str=$( _Vimh_only_existing_files "$files_list_str" )
	#log_debug_vimh "$func_name, lines(files_list_str)=(`echo -n "$files_list_str" | wc -l`)"
	#log_debug_vimh "$func_name, files_list_str=($files_list_str)"

	echo "$files_list_str"
}

_Vimh_read_paths_in_file() {
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
	local path_input="${1:-}"
	local filter_str="${2:-}"
	#	validate: path_input
	#	{{{
	if [[ ! -f "$path_input" ]]; then
		echo "$func_name, error, file not found, path_input=($path_input)" > /dev/stderr
		return 2
	fi
	#	}}}


	#	TODO: 2022-07-18T21:29:45AEST vimh-reader, oldest_date_included, report delta-now
	#oldest_date_included=$( cat "$path_input" | grep "$filter_str" | tail -n $_vimh_lines_limit | head -n 1 | awk -F'\t' '{print $1}' )
	#youngest_date_included=$( cat "$path_input" | grep "$filter_str" | tail -n $_vimh_lines_limit | tail -n 1 | awk -F'\t' '{print $1}' )
	oldest_date_included=$( cat "$path_input" | tail -n $_vimh_lines_limit | head -n 1 | awk -F'\t' '{print $1}' )
	youngest_date_included=$( cat "$path_input" | tail -n $_vimh_lines_limit | tail -n 1 | awk -F'\t' '{print $1}' )

	log_debug_vimh "$func_name, path_input=($path_input)"
	log_debug_vimh "$func_name, filter_str=($filter_str)"
	log_debug_vimh "$func_name, note: not using 'filter_str' -> reason it caused an issue unresolved"
	log_debug_vimh "$func_name, _vimh_lines_limit=($_vimh_lines_limit)"
	log_debug_vimh "$func_name, oldest_date_included=($oldest_date_included)"
	log_debug_vimh "$func_name, youngest_date_included=($youngest_date_included)"

	#	TODO: 2022-08-28T01:09:46AEST vimh-reader, identify reason passing log file through 'grep "$filter_str"' was causing issues
	#	Ongoing: 2022-08-28T01:03:37AEST bug is with 'grep "$filter_str"'? [...] somehow, it is causing newer lines to be rejected? (even though those same lines worked when we threw away all but the last few thousand lines?) -> 
	#	Ongoing: 2022-06-06T18:37:28AEST (requires that) grep does nothing given an empty argument(?)
	#result_str=$( cat "$path_input" | grep "$filter_str" | tail -n $_vimh_lines_limit | awk -F'\t' '{print $5}' )
	result_str=$( cat "$path_input" | tail -n $_vimh_lines_limit | awk -F'\t' '{print $5}' )

	#log_debug_vimh "$func_name, result_str=($result_str)"
	echo "$result_str"
}


_Vimh_only_existing_files() {
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
	local paths_list_str="${1:-}"
	paths_list_str=$( _Vimh_filter_files "$paths_list_str" )
	local IFS_temp=$IFS
	IFS=$nl
	local paths_list=( $( echo "$paths_list_str" ) ) 
	IFS=$IFS_temp
	for loop_path in "${paths_list[@]}"; do
		if [[ -f "$loop_path" ]]; then
			loop_path=$( echo -n "$loop_path" )
			echo "$loop_path"
		fi
	done
}


_Vimh_filter_files() {
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
	local paths_str="${1:-}"
	paths_str=$( echo "$paths_str" | grep -v "\/.git\/COMMIT_EDITMSG$" )
	echo "$paths_str"
}


_Vimh_only_dirs() {
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
	local IFS_temp=$IFS
	IFS=$nl
	local unique_files=( $( echo "${1:-}" ) )
	IFS=$IFS_temp
	local result_str=""
	for f in "${unique_files[@]}"; do
		if [[ ! -d $f ]]; then
			f=$( dirname "$f" )
		fi
		result_str=$result_str$nl$f
	done
	result_str=$( _Vimh_filter_dirs "$result_str" )
	if [[ -z "$result_str" ]]; then
		return
	fi
	echo "$result_str" | grep -v "^$" | tac | awk '!count[$0]++' | tac
}


_Vimh_filter_dirs() {
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
	local paths_str="${1:-}"
	paths_str=$( echo "$paths_str" | grep -v "^$HOME$" ) 
	echo "$paths_str"
}


#	Ongoing: 2022-06-06T02:42:37AEST can't use subshells if we want our use of 'cd' to effect the caller(?)
_Vimh_promptAndOpen() {
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
	local unique_files="${1:-}"
	local IFS_temp=$IFS
	IFS=$nl
	local prompt_files=( $( _Vimh_truncate_paths_to_screen "$unique_files" ) )
	IFS=$IFS_temp
	#	validate: prompt_files
	#	{{{
	if [[ ${#prompt_files[@]} -le 0 ]]; then
		echo "$func_name, error, len(prompt_files)=(${#prompt_files[@]})" > /dev/stderr
		return 2
	fi
	#	}}}
	log_debug_vimh "$func_name, len(prompt_files)=(${#prompt_files[@]})"

	_Vimh_print_prompt_files "${prompt_files[@]}" 

	local range_max="${#prompt_files[@]}"
	echo "Select [1, $range_max]:"
	local user_selection_path=$( _Vimh_promptUser_selectPath "$range_max" "$unique_files" )
	log_debug_vimh "$func_name, user_selection_path=($user_selection_path)"

	_Vimh_cd_and_open "$user_selection_path"
}


#	Ongoing: 2022-06-05T20:15:18AEST how to handle 'terminal window shorter than 4 / narrower than 12' case?
_Vimh_truncate_paths_to_screen() {
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
	local unique_files="${1:-}"
	local output_height=$(( `tput lines` - 10 ))
	local output_width=$(( `tput cols` - 8 ))
	#	ensure output_height and output_width > 1
	#	{{{
	if [[ $output_height -lt 1 ]]; then
		output_height=1
	fi
	if [[ $output_width -lt 1 ]]; then
		output_width=1
	fi
	#	}}}
	log_debug_vimh "$func_name, output_height=($output_height), output_width=($output_width)"

	local IFS_temp=$IFS
	IFS=$nl
	local prompt_files=( $( echo -n "$unique_files" | tail -n $output_height | sed "s|$HOME|~|g" ) )
	IFS=$IFS_temp
	log_debug_vimh "$func_name, len(prompt_files)=(${#prompt_files[@]})"

	for loop_file in "${prompt_files[@]}"; do
		if [[ `echo -n "$loop_file" | wc -c` -ge $output_width ]]; then
			local prepend_str="..."
			local cut_width=$(( $output_width - `echo -n "$prepend_str" | wc -c` ))
			loop_file="$prepend_str${loop_file: -$cut_width}"
		fi
		echo -n "$loop_file\n"
	done
}


#	Test: 2022-06-06T03:23:19AEST _Vimh_print_prompt_files (and our usage of 'func "${passed[@]}"' and 'recieved=("$@")') is not tricked by filenames/filepaths with spaces
_Vimh_print_prompt_files() {
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
	local prompt_files=( "$@" )
	log_debug_vimh "$func_name, len(prompt_files)=(${#prompt_files[@]})"

	i=${#prompt_files[@]}
	for loop_file in "${prompt_files[@]}"; do
		echo -n  "$i)  "
		echo -n "$loop_file\n"
		i=$(( $i - 1 ))
	done
}


_Vimh_promptUser_selectPath() {
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
	local range_max="$1"
	local unique_files="$2"
	#	validate: range_max
	#	{{{
	if [[ -z `echo "$range_max" | grep "^[[:digit:]]*$"` ]]; then
		echo "$func_name, error, invalid range_max=($range_max)"  > /dev/stderr
		return 2
	fi
	#	}}}
	local user_selection_num=""
	read user_selection_num
	#	validate: user_selection_num
	#	{{{
	if [[ -z `echo "$user_selection_num" | grep "^[[:digit:]]*$"` ]]; then
		echo "$func_name, error, invalid user_selection_num=($user_selection_num)" > /dev/stderr
		return 2
	fi
	if [[ ! $user_selection_num -gt 0 ]] || [[ ! $user_selection_num -le $range_max ]]; then
		echo "$func_name, error, invalid user_selection_num=($user_selection_num)" > /dev/stderr
		return 2
	fi
	#	}}}
	log_debug_vimh "$func_name, lines(unique_files)=(`echo "$unique_files" | wc -l`)"
	log_debug_vimh "$func_name, user_selection_num=($user_selection_num)"

	local user_selection_path=""
	user_selection_path=$( echo "$unique_files" | tail -n "$user_selection_num" | head -n 1 )
	log_debug_vimh "$func_name, user_selection_path=($user_selection_path)"

	echo "$user_selection_path"
}


_Vimh_cd_and_open() {
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
	local path_open="$1"
	#	validate: path_open
	#	{{{
	if [[ ! -e "$path_open" ]]; then
		echo "$func_name, error, not found, path_open=($path_open)" > /dev/stderr
		return 2
	fi
	#	}}}
	if [[ ! -d "$path_open" ]]; then
		local path_open_dir=$( dirname "$path_open" )
		echo cd "$path_open_dir"
		cd "$path_open_dir"
		echo $_vimh_editor "$path_open"
		$_vimh_editor "$path_open"
	else
		echo cd "$path_open"
		cd "$path_open"
	fi
}


_Vimh_Update_GlobalHistory() {
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
	local path_global=$( _Vimh_GetPath_GlobalHistory )
	local IFS_temp=$IFS
	IFS=$nl
	local path_locals=( $( _Vimh_GetPaths_CloudHistories ) )
	IFS=$IFS_temp
	local path_temp=$( mktemp )
	#	remove existing: path_global, path_temp
	#	{{{
	if [[ -f "$path_global" ]]; then
		log_debug_vimh "$func_name, delete path_global=($path_global)"
		rm "$path_global"
	fi
	if [[ -f "$path_temp" ]]; then
		log_debug_vimh "$func_name, delete path_temp=($path_temp)"
		rm "$path_temp"
	fi
	#	}}}
	for f in "${path_locals[@]}"; do
		log_debug_vimh "$func_name, f=($f)"
		cat "$f" | tail -n $_vimh_lines_limit >> "$path_temp"
	done
	cat "$path_temp" | sort -h > "$path_global"
}


_Vimh_GetPath_GlobalHistory() {
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
	#	validate: _vimh_path_dir_globalhistory, _vimh_name_globalhistory
	#	{{{
	if [[ ! -d "$_vimh_path_dir_globalhistory" ]]; then
		echo "$func_name, error, dir not found, _vimh_path_dir_globalhistory=($_vimh_path_dir_globalhistory)" > /dev/stderr
		return 2
	fi
	if [[ -z "$_vimh_name_globalhistory" ]]; then
		echo "$func_name, error, _vimh_name_globalhistory=($_vimh_name_globalhistory)" > /dev/stderr
		return 2
	fi
	#	}}}
	local path_str="$_vimh_path_dir_globalhistory/$_vimh_name_globalhistory"
	log_debug_vimh "$func_name, path_str=($path_str)"
	echo "$path_str"
}


_Vimh_GetPaths_CloudHistories() {
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
	#	validate existance: _vimh_path_dir_globalhistory
	#	{{{
	if [[ ! -d "$_vimh_path_dir_globalhistory" ]]; then
		echo "$func_name, error, dir not found, _vimh_path_dir_globalhistory=($_vimh_path_dir_globalhistory)" > /dev/stderr
		return 2
	fi
	#	}}}
	local IFS_temp=$IFS
	IFS=$nl
	local result=( $( find $_vimh_path_dir_globalhistory/*/$_vimh_name_globalhistory -print ) )
	IFS=$IFS_temp
	#	validate: result_str
	#	{{{
	if [[ "${#result[@]}" -le 0 ]]; then
		echo "$func_name, error, result=(${result[@]})" > /dev/stderr
		return 2
	fi
	#	}}}
	for f in "${result[@]}"; do
		log_debug_vimh "$func_name, f=($f)"
		#	validate: f
		#	{{{
		if [[ ! -f "$f" ]]; then
			echo "$func_name, error, file not found, f=($f)" > /dev/stderr
			return 2
		fi
		#	}}}
		echo "$f"
	done
}


#	{{{
#	Ongoing: 2022-06-04T23:17:26AEST problematic functions:
#_Vimh_filterLines_lastUnique() {
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
#	#	Requires reading from pipe (stdin?)
#}
#_Vimh_filter_realpaths() {
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
#	#	Ongoing: 2022-06-04T23:14:14AEST fast way to run 'readlink -f {}' on 100+ files?
#	#	No fast way to do this?
#	#	{{{
#	#if [[ -f "$loop_path" ]]; then
#	#	#echo $( _Vimh_get_fast_realpath "$loop_path" )
#	#	#realpath "$loop_path"
#	#	readlink -f "$loop_path"
#	#	#local temp_PWD=$PWD
#	#	#cd -P "`dirname "$loop_path"`"
#	#	#local output_dir="$PWD"
#	#	#local output_name="`basename "$loop_path"`"
#	#	#echo "$output_dir/$output_name"
#	#	#realpath --canonicalize-existing "$loop_path"
#	#	#realpath "$loop_path"
#	#	#readlink -f "$loop_path"
#	#	#realpath "$loop_path"
#	#	#if [[ ! -h "$loop_path" ]]; then
#	#	#	echo "$loop_path" 
#	#	#else
#	#	#	readlink "$loop_path"
#	#	#fi
#	#	#cd "$temp_PWD"
#	#fi
#	#	}}}
#}
#_Vimh_check_contains_symlink() {
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
#	#	LINK: https://serverfault.com/questions/1069147/how-can-i-quickly-test-a-path-in-bash-to-determine-if-any-segment-of-it-is-a-sym
#	#	If we can do this quickly as '[[ -L ]]', we can use 'echo' for files that pass and 'readlink -f' only where necessary
##	{{{
#	#local my_path="$1"
#	#if [[ "$my_path" != "$(realpath --canonicalize-existing $my_path)" ]];then
#	#  #echo The path $my_path is relative path or contains symlinks.
#	#  return 1
#	#else
#	#  #echo The path $my_path is absolute.
#	#  return 0
#	#fi
#	#local tmp="$1"
#	#while [ "$tmp" != "." ]; do
#	#	if [ -L "$tmp" ]; then
#	#		#/bin/echo "$tmp - is symlink."
#	#		return 1;
#	#	else
#	#		#/bin/echo "$tmp - is not symlink."
#	#		return 0;
#	#	fi
#	#	tmp=$(dirname $tmp)
#	#done
##	}}}
#}
#check_sourced=1
##	{{{
#if [[ -n "${ZSH_VERSION:-}" ]]; then 
#	if [[ ! -n ${(M)zsh_eval_context:#file} ]]; then
#		check_sourced=0
#	fi
#elif [[ -n "${BASH_VERSION:-}" ]]; then
#	(return 0 2>/dev/null) && check_sourced=1 || check_sourced=0
#else
#	echo "error, check_sourced, non-zsh/bash" > /dev/stderr
#	exit 2
#fi
##	}}}
#if [[ "$check_sourced" -eq 0 ]]; then
#	vimh "$@"
#fi
#	}}}


