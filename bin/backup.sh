#!/bin/bash

# Script for creating a backup of the following directories:
#	~/.dotfiles/
# 	~/downloads/
# 	~/media/
# 	~/workspace/
# 
# The usage of this script is as follows:
# 	backup.sh -v, --verbose		Enable verbosity.
# 	backup.sh -o, --output [file]	Write to [file].
#
# where [file] is the name of the file to write to.
#
# The resulting file is a tarball compressed with gzip.

# Basic variables.
VERBOSE=false
BACKUP_DIR=~/.backup
FILENAME="backup.tar.gz"

# Working directory of the user.
WORKING_DIR=$(pwd)

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

# Create temporary directory for backup.
log "Creating backup directory..."
rm -rf $BACKUP_DIR
mkdir -p $BACKUP_DIR
cd $BACKUP_DIR

# Copy directories.
log "Copying files..."
cp -r ~/.dotfiles ./dotfiles
cp -r ~/downloads .
cp -r ~/media .
cp -r ~/workspace .

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
