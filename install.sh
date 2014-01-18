#elementary OS install script for Chromebooks

#Variables definition
current_directory=$(dirname $0)
log_file="elementary-install.log"

#Functions definition
usage(){
    cat << EOF
		usage: $0

		elementary OS installation script for Chromebooks

		OPTIONS:
		   -h      show help.
EOF
}

debug_message(){
    echo "$1"
}

log_message(){
    message="$1"
    log_format="$(date +%Y-%m-%dT%H:%M:%S) $message"
    debug_message "$log_format" >> "$log_file"    
    debug_message "$message"
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
        *)
            usage
            exit 0
            ;;
    esac
done

log_message "Starting the installation process..."
