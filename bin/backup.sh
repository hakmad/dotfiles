#!/bin/bash

# Script for creating backups.
# 
# The usage of this script is as follows:
# 	backup.sh -v, --verbose		Verbose mode.
# 	backup.sh -o, --output [name]	File to output to.
# 
# This script is configured to backup the following directories:
# 	~/downloads
# 	~/media
# 	~/workspace
# 	~/.dotfiles

# Stop if there are errors.
set -e

# Initial variables.
VERBOSE=false
BACKUPDIR=~/.backup/
CURRENTDIR=$(pwd)
FILENAME="backup.tar.gz"

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

# Verbosity system for logging.
if [[ $VERBOSE = true ]]; then
	log() {
		echo "$@";
	}
else
	log() {
		:;
	}
fi

# Remove old backup directory and create new one.
log "Creating backup directory..."
rm -rf $BACKUPDIR
mkdir $BACKUPDIR
cd $BACKUPDIR

# Copy directories to backup directory.
log "Copying files..."
cp -r ~/.dotfiles ./dotfiles
cp -r ~/downloads .
cp -r ~/media .
cp -r ~/workspace .

# Create GZ compressed tarball from backup directory.
log "Creating $FILENAME..."
if [[ $VERBOSE = true ]]; then
	tar -czvf $FILENAME *
else
	tar -czf $FILENAME *
fi

# Move the tarball to home directory.
log "Moving $FILENAME to home directory..."
mv $FILENAME ~/

# Remove old files.
log "Cleaning up..."
cd $CURRENTDIR
rm -rf $BACKUPDIR

# Exit.
echo "Successfully created backup file: $FILENAME."
exit 0
