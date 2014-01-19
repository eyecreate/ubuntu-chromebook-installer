#!/bin/bash
#ChromeeOS - elementary OS install script for Chromebooks

#Variables definition
#Script variables
current_dir="$(dirname $BASH_SOURCE)"

#Script global directory variables
log_file="elementary-install.log"
log_dir="$current_dir/logs/"
tmp_dir="$current_dir/tmp/"
conf_dir="$current_dir/conf.d/"
devices_dir="$current_dir/devices/"
files_dir="$current_dir/files/"
scripts_dir="$current_dir/scripts/"
sys_files_dir="$files_dir/system/"
user_files_dir="$files_dir/user/"
web_dl_dir="$tmp_dir/web_dl/"

#Device specific variables
device_manifest="none"
dev_manifest_file="device.manifest"

#External depenencies variables 
#ChrUbuntu configuration file
chrubuntu_script="$scripts_dir/chrubuntu.sh"
chrubuntu_runonce="$tmp_dir/chrubuntu_runonce"

#elementary OS specific requirements
#A tar.gz version of elementary OS ISO (elementaryos-stable-amd64.20130810.iso) squashfs content 
eos_sys_archive_url="http://goo.gl/qXSqf3"
eos_sys_archive="$tmp_dir/elementary_system.tar.gz"
eos_sys_archive_md5=""

#Functions definition
usage(){
cat << EOF
usage: $0 -d [ DEVICE|ACTION ] [ OPTIONS ]
      
ChromeeOS - elmentary OS installation script for Chromebooks

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
    if [ -e "$log_dir" ];then
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
            debug_msg "WARNING" "Device not specified...exiting"
            usage
            exit 1
        elif [ ! -e "$device_manifest" ];then
            debug_msg "WARNING" "Device '$device_model' manifest does not exist...exiting"
            usage
            exit 1
        fi
        ;;
esac

debug_msg "INFO" "ChromeeOS - elementary OS installation script for Chromebooks by Setsuna666 on github Setsuna666/elementaryos-chromebook"
#Creating log files directory before using the log_msg function
if [ ! -e "$log_dir" ]; then
      mkdir $log_dir
fi

log_msg "INFO" "Device model is $device_model"

if [ ! -e "$tmp_dir" ]; then
      log_msg "INFO" "Creating and downloading dependencies..."
      run_command "mkdir $tmp_dir"
fi

if [ ! -e "$chrubuntu_runonce" ]; then
      log_msg "INFO" "Running ChrUbuntu to setup partitioning..."
      sudo bash $chrubuntu_script
      log_msg "INFO" "ChrUbuntu execution complete..."
      log_msg "INFO" "System will reboot in 10 seconds..."
      touch $chrubuntu_runonce
      sleep 10
      reboot
else
      log_msg "INFO" "ChrUbuntu partitioning already done...skipping"
      log_msg "INFO" "Running ChrUbuntu to finish the formating process..."
      sudo bash $chrubuntu_script
fi

log_msg "INFO" "Importing device $device_model manifest..."
. $device_manifest

log_msg "INFO" "Downloading elementary OS system files..."
run_command "curl -o '$eos_sys_archive' -L -O $eos_sys_archive_url"

log_msg "INFO" "Validation elementary OS system files archive md5sum..."
eos_sys_archive_dl_md5=$(md5sum $eos_sys_archive | awk '{print $1}')

#MD5 validation of eOS system files archive
if [ "$eos_sys_archive_md5" != "$eos_sys_archive_dl_md5" ];then
      log_msg "ERROR" "elementary OS system files archive MD5 does not match...exiting"
      run_command "rm $eos_sys_archive"
      log_msg "INFO" "Re-run this script to download the elementary OS system files archive..."
      exit 1
fi
