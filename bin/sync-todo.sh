#!/bin/bash

# Set variables for local and cloud todo locations.
local_todo="$HOME/todo/"
cloud_todo="fastmail:todo"
backup_dir="$HOME/media/backups/todo/$(date -I)/"

# Make a backup.
# I know that rclone has a backup option but I prefer doing this myself.
# (Also the backup option doesn't always seem to work...)
# Check if a backup has been made today.
if [[ ! -f $backup_dir$todo_file ]]; then
    # Create a new backup directory and copy the todo file there.
    mkdir -p $backup_dir
    cp -r $local_todo/. $backup_dir

    echo "Backed up $local_todo to $backup_dir"
fi

# Run a bidirectional sync using rclone. Check below for explanations:
# `--compare modtime` - comparisons are made based on modification time only.
# `--force` - there is an implicit `--max-delete` flag which prevents files from
#   being deleted above a certain percent. I don't actually care about that since
#   no files will be deleted from either side, so `--force` is need to make the sync
#   happen.
# `--conflict-resolve older` - if there is a conflict, choose the file that is older.
# `--verbose` - please say what you are actually doing.
rclone bisync $local_todo $cloud_todo --compare modtime --force --conflict-resolve older --verbose
