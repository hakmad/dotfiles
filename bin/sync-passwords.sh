#!/bin/bash

# Set variables for local and cloud password locations.
passwords_file="passwords.kdbx"
local_passwords="$HOME/.passwords/"
cloud_passwords="fastmail:passwords"
backup_dir="$HOME/.backups/passwords/$(date -I)/"

# Check if a backup has been made today.
if [[ ! -f $backup_dir$passwords_file ]]; then
    # Create a new backup directory and copy the passwords file there.
    mkdir -p $backup_dir
    cp $local_passwords$passwords_file $backup_dir

    echo "Backed up $local_passwords$passwords_file to $backup_dir$passwords_file"
fi


# Download file from the cloud (skip if the local version is newer than the
# cloud version).
echo "Syncing cloud to local..."
rclone sync $cloud_passwords $local_passwords --update -v

# Upload local file to the the cloud (skip if the cloud version is newer than
# the local version).
echo "Syncing local to cloud..."
rclone sync $local_passwords $cloud_passwords --update -v
