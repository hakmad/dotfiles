#!/bin/bash

# Script for creating a backup of the following directories:
# 	~/.dotfiles/
# 	~/downloads/
# 	~/media/
# 	~/workspace/
# 
# The usage of this script is as follows:
# 	backup.sh -v, --verbose		Enable verbosity.
# 	backup.sh -o, --output [file]	Write to [file].
# 	backup.sh -h, --help		Show this help.
# 
# where [file] is the name of the file to write to.
# 
# The resulting file is a tarball compressed with gzip.

# Basic variables.
VERBOSE=false
BACKUP_DIR=~/.backup/
FILENAME="${HOSTNAME}_backup_$(date "+%Y-%m-%d_%H-%M").tar.gz"

# Working directory of the user.
WORKING_DIR=$(pwd)

# Show help for this script.
show_help() {
	head ~/.bin/backup.sh -n 16 | tail -n 15 | sed "s/# //"
}

# Get command line arguments.
while [[ $1 != "" ]]; do
	case $1 in
		-v | --verbose)
			VERBOSE=true
			shift
			;;
		-o | --output)
			shift
			FILENAME=$1
			shift
			;;
		-h | --help)
			show_help
			exit
			;;
		*)
			shift
			;;
	esac
done

# Verbosity functions.
if [[ $VERBOSE == true ]]; then
	log() {
		echo "$@"
	}
else
	log() {
		:
	}
fi

# Notify user that backup is starting.
echo "Starting backup..."

# Create temporary directory for backup.
log "Creating backup directory..."
rm -rf $BACKUP_DIR
mkdir -p $BACKUP_DIR
cd $BACKUP_DIR

# Copy directories.
log "Copying files..."
cp -r ~/* .

# Create tarball.
log "Creating $FILENAME..."
if [[ $VERBOSE == true ]]; then
	tar -czvf $FILENAME *
else
	tar -czf $FILENAME *
fi

# Move resulting file to home directory.
log "Moving $FILENAME to home directory..."
mv $FILENAME ~/

# Clean up.
log "Cleaning up..."
rm -rf $BACKUP_DIR
cd $WORKING_DIR

echo "Successfully created backup file $FILENAME"
