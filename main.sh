#!/bin/bash
#ChromeeOS - elementary OS install script for Chromebooks

#Variables definition
#Script variables
current_dir="$(dirname $BASH_SOURCE)"
verbose=0

#Script global directory variables
log_file="elementary-install.log"
log_dir="$current_dir/logs/"
tmp_dir="$current_dir/tmp/"
conf_dir="$current_dir/conf.d/"
profiles_dir="$current_dir/profiles/"
devices_dir="$profiles_dir/devices/"
scripts_dir="$current_dir/scripts/"
web_dl_dir="$tmp_dir/web_dl/"

#Default profile
default_profile_file="default.profile"
default_profile_dir="$profiles_dir/default/"
default_sys_dir="$default_profile_dir/system/"
default_scripts_dir="$default_profile_dir/scripts/"

#User profile
user_profile_file="user.profile"
user_profile_dir="$profiles_dir/user/"
user_sys_dir="$user_profile_dir/user/system/"
user_scripts_dir="$user_profile_dir/scripts/"

#Device specific variables
device_profile="none"
dev_profile_file="device.profile"

#External depenencies variables
#ChrUbuntu configuration file
chrubuntu_script="$scripts_dir/chrubuntu-chromeeos.sh"
chrubuntu_runonce="$tmp_dir/chrubuntu_runonce"
system_chroot="/tmp/urfs/"

#elementary OS specific requirements
#A tar.gz version of elementary OS ISO (elementaryos-stable-amd64.20130810.iso) squashfs content 
eos_sys_archive_url="http://goo.gl/gX3XEE"
eos_sys_archive="$tmp_dir/elementaryos_system.tar.gz"
eos_sys_archive_md5="a9782e1772abe882a9dd567fde89105a"

#Functions definition
usage(){
cat << EOF
usage: $0 [ OPTIONS ] [ DEVICE_PROFILE | ACTION ]
      
ChromeeOS - elmentary OS installation script for Chromebooks

    OPTIONS:
    -h      Show help
    -v      Enable verbose mode

    DEVICE_PROFILE:
        The device profile to load for your Chromebook

    ACTIONS:
        list    List all the elements for this option (ex: List all devices profile supported)
        search  Search for your critera in all devices profile
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
        if [ "$debug_level" != "COMMAND" ];then
          debug_msg "$debug_level" "$msg"
        fi
    else
        debug_msg "ERROR" "Log directory $log_dir does not exist...exiting"
        exit 1
    fi
}

run_command(){
    command="$1"
    log_msg "COMMAND" "$command"
    cmd_output=$($command 2>&1)
    if [ "$cmd_output" != "" ];then
        log_msg "COMMAND" "output: $cmd_output"
    fi
}

run_command_chroot(){
  command="$1"
  log_msg "COMMAND" "$command"
  cmd_output=$(sudo chroot $system_chroot /bin/bash -c "$command" 2>&1)
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
        v)
            verbose=1
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done

device_model="${BASH_ARGV[0]}"
device_search="${BASH_ARGV[1]}"

if [ "$device_model" == "search" ];then
    debug_msg "WARNING" "No search critera entered for device profile search...exiting"
    usage
    exit 1
fi

if [ "$device_search" == "search" ];then
    search_result=$(/bin/bash $0 list | tail -n +3 | grep -i "$device_model")
    if [ -z "$search_result" ] || [ "$search_result" == "" ];then
        debug_msg "WARNING" "No device profile found with search critera \"$device_model\""
    else
        debug_msg "INFO" "List of device profile matching search critera \"$device_model\""
        echo $search_result
    fi
    exit 1
fi

#Validate device model
case "$device_model" in
    list) 
        debug_msg "INFO" "List of device profiles for supported devices..."
        for i in $(cd $devices_dir; ls -d */); do echo "- ${i%%/}"; done
        exit 0
        ;;
    *)
        device_profile="$devices_dir/$device_model/$dev_profile_file"
        device_profile_dir="$devices_dir/$device_model/"
        device_scripts_dir="$device_profile_dir/scripts/"
        device_files_dir="$device_profile_dir/files/"
        device_sys_dir="$device_files_dir/system/"
        if [ -z "$device_model" ]; then
            debug_msg "WARNING" "Device not specified...exiting"
            usage
            exit 1
        elif [ ! -e "$device_profile" ];then
            debug_msg "WARNING" "Device '$device_model' profile does not exist...exiting"
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

device_hwid=$(crossystem hwid)
log_msg "INFO" "Device model is $device_model"
log_msg "INFO" "Device hardware ID is $device_hwid"

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
    sudo reboot
    exit 0
else
    log_msg "INFO" "ChrUbuntu partitioning already done...skipping"
    log_msg "INFO" "Running ChrUbuntu to finish the formating process..."
    sudo bash $chrubuntu_script
fi

log_msg "INFO" "Importing device $device_model profile..."
. $device_profile

#Validating that required variables are defined in the device profile
if [ -z "$system_drive" ];then
    log_msg "ERROR" "System drive (system_drive) variable not defined in device profile $device_profile...exiting"
    exit 1
fi

if [ -z "$system_partition" ];then
    log_msg "ERROR" "System partition (system_partition) variable not defined in device profile $device_profile...exiting"
    exit 1
fi

#Verify if the swap file option in specified in the device profile
if [ -z "$swap_file_size" ];then 
    log_msg "ERROR" "Swap file size (swap_file_size) variable is not defined in device profile $device_profile...exiting"
    exit 1
fi

if [ ! -e "$system_drive" ];then
    log_msg "ERROR" "System drive $system_drive does not exist...exiting"
    exit 1
fi

if [ ! -e "$system_partition" ];then
    log_msg "ERROR" "System drive $system_partition does not exist...exiting"
    exit 1
fi

log_msg "INFO" "Downloading elementary OS system files..."
if [ ! -e "$eos_sys_archive" ];then
    curl -o "$eos_sys_archive" -L -O "$eos_sys_archive_url"
else
    log_msg "INFO" "elementary OS system files are already downloaded...skipping"
fi

log_msg "INFO" "Validating elementary OS system files archive md5sum..."
eos_sys_archive_dl_md5=$(md5sum $eos_sys_archive | awk '{print $1}')

#MD5 validation of eOS system files archive
if [ "$eos_sys_archive_md5" != "$eos_sys_archive_dl_md5" ];then
    log_msg "ERROR" "elementary OS system files archive MD5 does not match...exiting"
    run_command "rm $eos_sys_archive"
    log_msg "INFO" "Re-run this script to download the elementary OS system files archive..."
    exit 1
else
  log_msg "INFO" "elementary OS system files archive MD5 match...continuing"
fi

log_msg "INFO" "Installing elementary OS system files to $system_chroot..."
run_command "tar -xvf $eos_sys_archive -C $system_chroot"

if [ -e "$default_sys_dir" ];then
    log_msg "INFO" "Copying global system files to $system_chroot..."
    run_command "sudo cp -Rvu $default_sys_dir/. $system_chroot"
else
    log_msg "INFO" "No global system files found...skipping"
fi

if [ -e "$device_sys_dir" ];then
    log_msg "INFO" "Copying device system files to $system_chroot..."
    run_command "sudo cp -Rvu $device_sys_dir/. $system_chroot"
else
    log_msg "INFO" "No device system files found...skipping"
fi

if [ -e "$device_scripts_dir" ];then
    scripts_dir="/tmp/scripts/"
    chroot_dir_scripts="$system_chroot/tmp/scripts/"
    log_msg "INFO" "Copying device scripts to $chroot_dir_scripts..."
    run_command "mkdir -p $chroot_dir_scripts"
    run_command "sudo cp -Rvu $device_scripts_dir/. $chroot_dir_scripts"
else
    log_msg "INFO" "No device scripts found...skipping"
fi

log_msg "INFO" "Mounting dependencies for the chroot..."
run_command "sudo mount -o bind /dev/ $system_chroot/dev/"
run_command "sudo mount -o bind /dev/pts $system_chroot/dev/pts"
run_command "sudo mount -o bind /sys/ $system_chroot/sys/"
run_command "sudo mount -o bind /proc/ $system_chroot/proc/"

log_msg "INFO" "Creating /etc/resolv.conf..."
echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > $tmp_dir/resolv.conf
run_command "sudo mv $tmp_dir/resolv.conf $system_chroot/etc/resolv.conf"
system_partition_uuid=$(sudo blkid $system_partition | sed -n 's/.*UUID=\"\([^\"]*\)\".*/\1/p')
log_msg "INFO" "Getting UUID from system partition..."
log_msg "INFO" "Creating /etc/fstab..."
echo -e "proc  /proc nodev,noexec,nosuid  0   0\nUUID=$system_partition_uuid  / ext4  noatime,nodiratime,errors=remount-ro  0   0\n/swap.img  none  swap  sw  0   0" > $tmp_dir/fstab
run_command "sudo mv $tmp_dir/fstab $system_chroot/etc/fstab"

log_msg "INFO" "Installing elementary OS updates..."
run_command_chroot "export DEBIAN_FRONTEND=noninteractive; apt-get -y -q update"
run_command_chroot "export DEBIAN_FRONTEND=noninteractive; apt-get -y -q upgrade"

#Device profile validation for the installation ofkernel packages from an URL
if [ ! -z "$kernel_url_pkgs" ];then
    kernel_url_pkgs_array=($kernel_url_pkgs)
    kernel_dir="/tmp/kernel/"
    log_msg "INFO" "Downloading and installing kernel package(s) from URL"
    run_command_chroot "mkdir $kernel_dir"
    for kernel_pkg in "${kernel_url_pkgs_array[@]}";do
        run_command_chroot "wget -P $kernel_dir $kernel_pkg"
    done
    run_command_chroot "dpkg -i $kernel_dir/*.deb"
fi

#Device profile validation for the installation additional packages from PPA
if [ ! -z "$ppa_pkgs" ];then
    ppa_pkgs_array=($ppa_pkgs)
    log_msg "INFO" "Installing packages from PPA..."
    for ppa_pkg in "${ppa_pkgs_array[@]}";do
        run_command_chroot "export DEBIAN_FRONTEND=noninteractive; apt-get -y -q update"
        run_command_chroot "export DEBIAN_FRONTEND=noninteractive; apt-get -y -q install $ppa_pkg"
    done
fi

#Verification for the chroot scripts directory
if [ -e "$chroot_dir_scripts" ];then
    log_msg "INFO" "Executing device scripts..."
    for i in $(cd $chroot_dir_scripts; ls);do
        run_command_chroot "chmod a+x $scripts_dir/${i%%/}"
        run_command_chroot "/bin/bash -c $scripts_dir/${i%%/}"
    done
fi

log_msg "INFO" "Creating swap file..."
run_command_chroot "fallocate -l $swap_file_size /swap.img"
run_command_chroot "mkswap /swap.img"
run_command_chroot "chown root:root /swap.img"
run_command_chroot "chmod 0600 /swap.img"

log_msg "INFO" "Finishing configuration for elementary OS..."
run_command_chroot "chown root:messagebus /usr/lib/dbus-1.0/dbus-daemon-launch-helper"
run_command_chroot "chmod u+s /usr/lib/dbus-1.0/dbus-daemon-launch-helper"
run_command_chroot "rm /etc/skel/.config/plank/dock1/launchers/ubiquity.dockitem"
run_command_chroot "export DEBIAN_FRONTEND=noninteractive; apt-get -y -q remove gparted"
run_command_chroot "rm -rf /tmp/*"
run_command_chroot "chmod -R 777 /tmp/"

log_msg "INFO" "Creating hosts file..."
echo -e "127.0.0.1  localhost\n127.0.1.1  $system_computer_name\n# The following lines are desirable for IPv6 capable hosts\n::1     ip6-localhost ip6-loopback\nfe00::0 ip6-localnet\nff00::0 ip6-mcastprefix\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters" > $tmp_dir/hosts
run_command "sudo mv $tmp_dir/hosts $system_chroot/etc/hosts"

log_msg "INFO" "Enabling user and system configuration on first boot..."
run_command_chroot "export DEBIAN_FRONTEND=noninteractive; apt-get -y -q update"
run_command_chroot "export DEBIAN_FRONTEND=noninteractive; apt-get -y -q install oem-config"
run_command_chroot "touch /var/lib/oem-config/run"

log_msg "INFO" "Installing and updating grub to $system_drive..."
run_command_chroot "grub-install $system_drive --force"
run_command_chroot "update-grub"

log_msg "INFO" "Unmounting chroot dependencies and file system..."
run_command "sudo umount $system_chroot/dev/pts"
run_command "sudo umount $system_chroot/dev/"
run_command "sudo umount $system_chroot/sys"
run_command "sudo umount $system_chroot/proc"
run_command "sudo umount $system_chroot"

log_msg "INFO" "elementary OS installation completed. On first boot you will be asked to do the initial configuration for your system language, timezone, computer name and user account"
log_msg "INFO" "Press [ENTER] to reboot..."
read
run_command "sudo reboot"
