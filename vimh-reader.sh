#!/usr/bin/env zsh
#	{{{3
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
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
#	Ongoing: 2022-07-18T21:28:33AEST slow *and* NOT IMPLEMENTED? '_vimh_flag_only_realpaths' [...] implementation has been disabled for being slow (but exists(?))
#	Ongoing: 2023-03-19T11:32:30AEDT _Vimh_print_prompt_files (and our usage of 'func "${passed[@]}"' and 'recieved=("$@")') appears to work for filenames with spaces
#	2023-05-20T20:04:41AEST can't 'log_debug_vim' recieve it's argument without '$func_name' (that being something that will still be in scope?)
#	2023-06-02T19:54:47AEST '--follow' generally unneccessary (since only realpaths are written to ~/.vimh)
#	}}}

_vimh_flag_debug=0
log_debug_vimh() { if [[ $_vimh_flag_debug -ne 0 ]]; then echo "$@" > /dev/stderr; fi }

#	local history file
_vimh_path_localhistory="$HOME/.vimh"

#	global history 
_vimh_path_dir_globalhistory="$mld_out_cloud_shared/combined-logs"
_vimh_name_globalhistory="vimh.vi.txt"

##	NOT IMPLEMENTED (slow) convert every path to realpath
#_vimh_flag_only_realpaths=0		

#	application to open files
_vimh_editor="$EDITOR"

#	number of lines to read from log file(s) (set to 0 for all)
_vimh_lines_limit=50000

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

_vimh_bin_date=date

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
	local _vimh_version="0.1.3"
	local func_about="Utility for finding/opening recent items from vimh log"
	local func_help="""$func_name, $_vimh_version
$func_about
Usage:
    -f | --filter [val]      Filter input lines with value
    -g | --global            Use combined logs from 'mld_out_cloud_shared'
    -d | --dirs              Get list of unique dirs
    -r | --repos             Only dirs containing git repos (enables --dirs)
    -i | --imaginary         Include files not found on filesystem
    -c | --count             (UNIMPLEMENTED) Sort result by occurences count
    -s | --start  [start]    (UNIMPLEMENTED) Start filter date
    -e | --end    [end]      (UNIMPLEMENTED) End filter date
    -R | --report [interval] (UNIMPLEMENTED) Report counts by interval [y/m/d]
    -m | --limit  [limit]    Max lines in history (0 = unlimited)
    -l | --long              Do not limit choices to length of screen
    -n | --noprompt          Do not ask for choice (and do not shorten paths)
    -L | --follow            Output only realpaths (slow)
    --notilde                Don't replace s/\$HOME/~/
    -v | --debug
    -h | --help
    --version
"""
	#	{{{
	if echo "${1:-}" | perl -wne '/^\s*-h|--help\s*$/ or exit 1'; then
		echo "$func_help"
		return 2
	fi
	#	}}}

	local filter_str=""
	local flag_global=0
	local flag_dirs=0
	local flag_repos=0
	local flag_imaginary=""
	local flag_only_most_recents=1
	local flag_skip_prompt_open=0
	local flag_only_realpaths=0
	local flag_home_as_tilde=1

	#	parse args "$@"
	#	{{{
	while [[ $# -gt 0 ]]; do
		case $1 in
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
			-r|--repos)
				flag_dirs=1
				flag_repos=1
				shift
				;;
			-h|--help)
				echo "$func_help"
				return 2
				shift
				;;
			-i|--imaginary)
				flag_imaginary="--imaginary"
				shift
				;;
			-m|--limit)
				local _vimh_lines_limit="$2"
				if [[ ! "$_vimh_lines_limit" =~ ^[0-9]+$ ]]; then
					echo "$func_name, error, --limit must be a non-negative integer,_vimh_lines_limit=($_vimh_lines_limit)" > /dev/stderr
					return 2
				fi
				shift
				shift
				;;
			-l|--long)
				flag_only_most_recents=0
				shift
				;;
			-n|--noprompt)
				flag_skip_prompt_open=1
				shift
				;;
			-L|--follow)
				flag_only_realpaths="--readlink"
				shift
				;;
			--notilde)
				flag_home_as_tilde=0
				shift
				;;
			-v|--debug)
				local _vimh_flag_debug=1
				shift
				;;
			--version)
				echo "$_vimh_version"
				return 2
				shift
				;;
			-*|--*)
				echo "Unknown option '$1'" > /dev/stderr
				return 2
				shift
				;;
			*)
				echo "Invalid argument '$1'" > /dev/stderr
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
	local unique_files=$( _Vimh_get_uniquepaths "$path_input" "$filter_str" "$flag_imaginary" "$flag_only_realpaths" )
	if [[ $flag_dirs -ne 0 ]]; then
		unique_files=$( _Vimh_only_dirs "$unique_files" )
	fi
	if [[ $flag_repos -ne 0 ]]; then
		unique_files=$( _Vimh_only_repo_dirs "$unique_files" )
	fi

	#	Ongoing: 2022-06-06T01:37:14AEST can't capture output of '_Vimh_promptAndOpen' as a subshell and also display output from it before prompting for input from it (that is, can't move call to '_Vimh_cd_and_open' out of it)
	_Vimh_promptAndOpen "$unique_files"
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
	local flag_imaginary="${3:-}"
	local flag_only_realpaths="${4:-}"
	#	validate: path_input
	#	{{{
	if [[ ! -f "$path_input" ]]; then
		echo "$func_name, error, file not found, path_input=($path_input)" > /dev/stderr
		return 2
	fi
	#	}}}

	#if [[ $_vimh_flag_only_realpaths -ne 0 ]]; then
	#	echo "$func_name, error, _Vimh_filter_realpaths not available" > /dev/stderr
	#	return 2
	#	#unique_files_list_str=$( _Vimh_filter_realpaths "$unique_files_list_str" | tac | awk '!count[$0]++' | tac )
	#fi

	local read_files_str=$( _Vimh_read_paths_in_file "$path_input" "$filter_str" )
	log_debug_vimh "$func_name, lines(read_files_str)=(`echo $read_files_str | wc -l`)"
	#log_debug_vimh "$func_name, read_files_str=($read_files_str)"

	if [[ $flag_only_realpaths == "--readlink" ]]; then
		read_files_str=$( echo "$read_files_str" | tac | awk '!count[$0]++' | tac )
		read_files_str=$( _Vimh_resolve_symlinks "$read_files_str" )
	fi

	local unique_files_list_str=$( echo "$read_files_str" | tac | awk '!count[$0]++' | tac )
	log_debug_vimh "$func_name, lines(unique_files_list_str)=(`echo $unique_files_list_str | wc -l`)"
	#log_debug_vimh "$func_name, unique_files_list_str=($unique_files_list_str)"

	#	validate non-empty: unique_files_list_str
	#	{{{
	if [[ -z "$unique_files_list_str" ]]; then
		echo "$func_name, error, unique_files_list_str=($unique_files_list_str)" > /dev/stderr
		return 2
	fi
	#	}}}

	if [[ $flag_imaginary == "--imaginary" ]]; then
		log_debug_vimh "$func_name, skip filter _Vimh_only_existing_files"
		echo "$unique_files_list_str"
		return
	fi

	existing_unique_files_list_str=$( _Vimh_only_existing_files "$unique_files_list_str" )
	log_debug_vimh "$func_name, lines(existing_unique_files_list_str)=(`echo "$existing_unique_files_list_str" | wc -l`)"
	#log_debug_vimh "$func_name, existing_unique_files_list_str=($existing_unique_files_list_str)"

	echo "$existing_unique_files_list_str"
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

	#	{{{
	#	disabled grep filtering
	#oldest_date_included=$( cat "$path_input" | grep "$filter_str" | tail -n $_vimh_lines_limit | head -n 1 | awk -F'\t' '{print $1}' )
	#youngest_date_included=$( cat "$path_input" | grep "$filter_str" | tail -n $_vimh_lines_limit | tail -n 1 | awk -F'\t' '{print $1}' )
	#oldest_date_included=$( cat "$path_input" | tail -n $_vimh_lines_limit | head -n 1 | awk -F'\t' '{print $1}' )
	#youngest_date_included=$( cat "$path_input" | tail -n $_vimh_lines_limit | tail -n 1 | awk -F'\t' '{print $1}' )
	#	}}}

	if [[ "$_vimh_lines_limit" -eq 0 ]]; then
		oldest_date_included=$( cat "$path_input" | grep --text -v "^#" | grep --text "$filter_str" | head -n 1 | awk -F'\t' '{print $1}' )
		youngest_date_included=$( cat "$path_input" | grep --text -v "^#" | grep --text "$filter_str" | tail -n 1 | awk -F'\t' '{print $1}' )
	else
		oldest_date_included=$( cat "$path_input" | grep --text -v "^#" | grep --text "$filter_str" | tail -n $_vimh_lines_limit | head -n 1 | awk -F'\t' '{print $1}' )
		youngest_date_included=$( cat "$path_input" | grep --text -v "^#" | grep --text "$filter_str" | tail -n $_vimh_lines_limit | tail -n 1 | awk -F'\t' '{print $1}' )
	fi

	current_epoch=`$_vimh_bin_date "+%s"`
	oldest_epoch_included=$( $_vimh_bin_date --date="$oldest_date_included" "+%s" )
	youngest_epoch_included=$( $_vimh_bin_date --date="$youngest_date_included" "+%s" )
	delta_d_oldest_date_included=$( perl -E "printf('%g', ($current_epoch - $oldest_epoch_included)/(24*60*60) )" )
	delta_s_youngest_date_included=$( perl -E "say( $current_epoch - $youngest_epoch_included )" )
	#	warning if delta_s_youngest_date_included > some_threshold?

	#	log_debug_vimh: path_input, filter_str, _vimh_lines_limit, oldest_date_included, youngest_date_included
	#	{{{
	log_debug_vimh "$func_name, path_input=($path_input)"
	#log_debug_vimh "$func_name, note: not using 'grep \"\$filter_str\"' -> reason it caused an issue unresolved [...] (re-enabled with '--text' flag)"
	log_debug_vimh "$func_name, filter_str=($filter_str)"
	log_debug_vimh "$func_name, _vimh_lines_limit=($_vimh_lines_limit)"
	log_debug_vimh "$func_name, oldest_date_included=($oldest_date_included)"
	log_debug_vimh "$func_name, youngest_date_included=($youngest_date_included)"
	log_debug_vimh "$func_name, delta_d_oldest_date_included=($delta_d_oldest_date_included)"
	log_debug_vimh "$func_name, delta_s_youngest_date_included=($delta_s_youngest_date_included)"
	#	}}}

	#	Ongoing: 2022-06-06T18:37:28AEST (requires that) grep does nothing given an empty argument(?) [...] (I mean it does?) [...] (and we test for this?)
	#	{{{
	#	disabled grep filtering
	#result_str=$( cat "$path_input" | grep "$filter_str" | tail -n $_vimh_lines_limit | awk -F'\t' '{print $6}' )
	#result_str=$( cat "$path_input" | tail -n $_vimh_lines_limit | awk -F'\t' '{print $6}' )
	#	}}}
	if [[ "$_vimh_lines_limit" -eq 0 ]]; then
		result_str=$( cat "$path_input" | grep --text -v "^#" | grep --text "$filter_str" | awk -F'\t' '{print $6}' )
	else
		result_str=$( cat "$path_input" | grep --text -v "^#" | grep --text "$filter_str" | tail -n $_vimh_lines_limit | awk -F'\t' '{print $6}' )
	fi
	log_debug_vimh "$func_name, lines(result_str)=(`echo $result_str | wc -l`)"
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
	IFS=$'\n'
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
	#paths_str=$( echo "$paths_str" | grep --text -v "\/.git\/COMMIT_EDITMSG$" )
	paths_str=$( echo "$paths_str" | grep --text -v "\.git$" )
	paths_str=$( echo "$paths_str" | grep --text -v "COMMIT_EDITMSG$" )
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
	IFS=$'\n'
	local unique_files=( $( echo "${1:-}" ) )
	IFS=$IFS_temp
	local result_str=""
	for f in "${unique_files[@]}"; do
		if [[ ! -d $f ]]; then
			f=$( dirname "$f" )
		fi
		result_str=$result_str$'\n'$f
	done
	result_str=$( _Vimh_filter_dirs "$result_str" )
	if [[ -z "$result_str" ]]; then
		return
	fi
	echo "$result_str" | grep --text -v "^$" | tac | awk '!count[$0]++' | tac
}

_Vimh_only_repo_dirs() {
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
	IFS=$'\n'
	local unique_dirs=( $( echo "${1:-}" ) )
	IFS=$IFS_temp
	local result_str=""
	for d in "${unique_dirs[@]}"; do
		if [[ -d "$d" ]]; then
			local previous_PWD=$PWD
			cd "$d"
			if git rev-parse --is-inside-work-tree --quiet > /dev/null 2>&1; then
				relative_root=`git rev-parse --show-cdup`
				cd "$relative_root"
				root=$PWD
				result_str=$result_str$'\n'$root
			fi
			cd "$previous_PWD"
		fi
	done
	if [[ ! -z "$result_str" ]]; then
		echo "$result_str" | grep --text -v "^$" | tac | awk '!count[$0]++' | tac
	fi
}

_Vimh_resolve_symlinks() {
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
	IFS=$'\n'
	local paths_str=( $( echo "${1:-}" ) )
	IFS=$IFS_temp
	local result_str=""
	local f_resolved=""
	for f in "${paths_str[@]}"; do
		f_resolved=`readlink -f "$f"`
		#log_debug_vimh "$func_name, f=($f), f_resolved=($f_resolved)"
		#result_str=$result_str$'\n'$f_resolved
		echo "$f_resolved"
	done
	#echo "$result_str"
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
	paths_str=$( echo "$paths_str" | grep --text -v "^$HOME$" ) 
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
	IFS=$'\n'
	local promp_files=""
	prompt_files=( $( _Vimh_truncate_paths_to_screen "$unique_files" ) )
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

	if [[ $flag_skip_prompt_open -ne 0 ]]; then
		log_debug_vimh "$func_name, skip prompt open" 
		return
	fi

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

	#	log_debug:
	#	{{{
	log_debug_vimh "$func_name, output_height=($output_height), output_width=($output_width)"
	log_debug_vimh "$func_name, flag_only_most_recents=($flag_only_most_recents)"
	log_debug_vimh "$func_name, flag_skip_prompt_open=($flag_skip_prompt_open)"
	log_debug_vimh "$func_name, flag_home_as_tilde=($flag_home_as_tilde)"
	#	}}}

	#	{{{
	#if [[ $flag_only_most_recents -ne 0 ]]; then
	#	local prompt_files_str=( $( echo -n "$unique_files" | tail -n $output_height | sed "s|$HOME|~|g" ) )
	#else
	#	local prompt_files_str=( $( echo -n "$unique_files" | sed "s|$HOME|~|g" ) )
	#fi
	#	}}}
	if [[ $flag_only_most_recents -ne 0 ]]; then
		unique_files=$( echo -n "$unique_files" | tail -n $output_height )
	fi
	if [[ $flag_home_as_tilde -ne 0 ]]; then
		unique_files=$( echo -n "$unique_files" | sed "s|$HOME|~|g" )
	fi
	local IFS_temp=$IFS
	IFS=$'\n'
	local prompt_files=( $( echo -n "$unique_files" ) )
	IFS=$IFS_temp
	log_debug_vimh "$func_name, len(prompt_files)=(${#prompt_files[@]})"

	for loop_file in "${prompt_files[@]}"; do
		if [[ $flag_skip_prompt_open -eq 0 ]] && [[ `echo -n "$loop_file" | wc -c` -ge $output_width ]]; then
			local prepend_str="..."
			local cut_width=$(( $output_width - `echo -n "$prepend_str" | wc -c` ))
			loop_file="$prepend_str${loop_file: -$cut_width}"
		fi
		echo -n "$loop_file\n"
	done
}


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
	log_debug_vimh "$func_name, flag_skip_prompt_open=($flag_skip_prompt_open)"

	if [[ $flag_skip_prompt_open -ne 0 ]]; then
		for loop_file in "${prompt_files[@]}"; do
			echo -n "$loop_file\n"
		done
		return
	fi

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
	if [[ -z `echo "$range_max" | grep --text "^[[:digit:]]*$"` ]]; then
		echo "$func_name, error, invalid range_max=($range_max)"  > /dev/stderr
		return 2
	fi
	#	}}}
	local user_selection_num=""
	read user_selection_num
	#	validate: user_selection_num
	#	{{{
	if [[ -z `echo "$user_selection_num" | grep --text "^[[:digit:]]*$"` ]]; then
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
	IFS=$'\n'
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
		if [[ "$_vimh_lines_limit" -eq 0 ]]; then
			cat "$f" | grep --text -v "^#" >> "$path_temp"
		else
			cat "$f" | grep --text -v "^#" | tail -n $_vimh_lines_limit >> "$path_temp"
		fi
	done
	cat "$path_temp" | grep --text -v "^#" | sort -h > "$path_global"
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
	IFS=$'\n'
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


