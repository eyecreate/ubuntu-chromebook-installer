#!/bin/bash
#elementary OS install script for Chromebooks

#Variables definition
#Script variables
current_dir=$(dirname $0)
log_dir="$current_dir/logs/"
log_file="elementary-install.log"
tmp_dir="$current_dir/tmp/"

#External depenencies variables 
chrubuntu_script_url="http://goo.gl/9sgchs"
chrubuntu_script="9sgchs"

#Functions definition
usage(){
    cat << EOF
		usage: $0

		elementary OS installation script for Chromebooks

		OPTIONS:
		   -h      show help.
EOF
}

debug_msg(){
    debug_level="$1"
    msg="$2"
    case $debug_level in
        INFO)
            echo -e "\E[1;32m$msg"
            echo -e '\e[0m'
            ;;
        WARNING)
            echo -e "\E[1;33m$msg"
            echo -e '\e[0m'
            ;;
        ERROR)
            echo -e "\E[1;31m$msg"
            echo -e '\e[0m'
            ;;
        *)
            echo "$msg"
            echo -e '\e[0m'
            ;;
    esac
}

log_msg(){
    if [ -e "$log_dir/" ];then
        debug_level="$1"
        msg="$2"
        log_format="$(date +%Y-%m-%dT%H:%M:%S) $debug_level $msg"
        echo "$log_format" >> "$log_dir/$log_file"    
        debug_msg "$debug_level" "$msg"
    else
        debug_msg "ERROR" "Log directory $log_dir does not exist...exiting"
        exit 1
    fi
}

run_command(){
    command="$1"
    cmd_output=$($command 2>&1)
    log_msg "COMMAND" "running: $command"
    if [ "$cmd_output" != "" ];then
        log_msg "COMMAND" "output: $cmd_output"
    fi
}


#Get command line arguments
while getopts ":h" options; do
    case "${options}" in
        h)
            usage
            exit 0
            ;;
        :)
            echo "Error - Option $OPTARG requires an argument"
            exit 1
            ;;
    esac
done

debug_msg "INFO" "elementary OS installation script for Chromebooks by Setsuna666 on github Setsuna666/elementaryos-chromebook"

log_msg "INFO" "Creating and downloading dependencies..."
run_command "mkdir $log_dir"
run_command "mkdir $tmp_dir"

log_msg "INFO" "Downloading ChrUbuntu..."
run_command "curl -o $tmp_dir/$chrubuntu_script -L -O $chrubuntu_script_url"

log_msg "INFO" "Running ChrUbuntu..."
run_command "sudo bash $tmp_dir/$chrubuntu_script -h" 


