#!/bin/bash
#elementary OS install script for Chromebooks

#Variables definition
#Script variables
current_dir=$(dirname $0)
log_dir="$current_dir/logs/"
log_file="elementary-install.log"
tmp_dir="$current_dir/tmp/"
devices_dir="$current_dir/devices/"
files_dir="$current_dir/files/"
sys_files_dir="$files_dir/system/"
user_files_dir="$files_dir/user/"
device_manifest="none"
dev_manifest_file="device.manifest"

#External depenencies variables 
chrubuntu_script_url="http://goo.gl/9sgchs"
chrubuntu_script="9sgchs"
chrubuntu_runonce="$tmp_dir/chrubuntu-runonce"

#Functions definition
usage(){
cat << EOF
usage: $0 -d [ DEVICE|ACTION ] [ OPTIONS ]
      
ementary OS installation script for Chromebooks

    OPTIONS:
    -h      Show help
    -d      Specify a device or an action

    DEVICE:
        The device manifest to load for your Chromebook

    ACTION:
        list    List all the elements for this specific options (ex: List all devices model supported"
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
#Required arguments

#Optional arguments
while getopts "hd:" option; do
    case $option in
        h)
            usage
            exit 1
            ;;
        d)
            device_model="$OPTARG"
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done

#Validate device model
case "$device_model" in
    list) 
        debug_msg "INFO" "List of supported devices..."
        for i in $(cd $devices_dir; ls -d */); do echo "- ${i%%/}"; done
        exit 0
        ;;
    *)
        device_manifest="$devices_dir/$device_model/$dev_manifest_file"
        if [ -z "$device_model" ]; then
            log_msg "WARNING" "Device not specified...exiting"
            usage
            exit 1
        elif [ ! -e "$device_manifest" ];then
            log_msg "WARNING" "Device '$device_model' manifest does not exist...exiting"
            usage
            exit 1
        fi
        ;;
esac

debug_msg "INFO" "elementary OS installation script for Chromebooks by Setsuna666 on github Setsuna666/elementaryos-chromebook"

log_msg "INFO" "Device model is $device_model"
log_msg "INFO" "Creating and downloading dependencies..."
run_command "mkdir $log_dir"
run_command "mkdir $tmp_dir"

log_msg "INFO" "Downloading ChrUbuntu..."
run_command "curl -o $tmp_dir/$chrubuntu_script -L -O $chrubuntu_script_url"

if [ ! -e "$chrubuntu_runonce" ];then
    log_msg "INFO" "Running ChrUbuntu..."
    sudo bash $tmp_dir/$chrubuntu_script -h 
    log_msg "INFO" "ChrUbuntu execution complete..."
    log_msg "INFO" "Creating ChrUbuntu run once file..."
    run_command "touch $chrubuntu_runonce"
else
    log_msg "WARNING" "ChrUbuntu has already been run once...skipping"
fi


