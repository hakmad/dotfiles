#!/bin/bash

# Set variables for local and cloud todo locations.
local_todo="$HOME/todo/"
cloud_todo="fastmail:todo"
local_backup="$HOME/.backups/todo/$(date -I)/"

# Run a bidirectional sync using rclone. Check below for explanations:
# `--compare modtime` - comparisons are made based on modification time only.
# `--force` - there is an implicit `--max-delete` flag which prevents files from
#   being deleted above a certain percent. I don't actually care about that since
#   no files will be deleted from either side, so `--force` is need to make the sync
#   happen.
# `--backup-dir1 $local_backup` - path to back files up to on this side (my laptop).
# `--conflict-resolve older` - if there is a conflict, choose the file that is older.
# `--create-empty-src-dirs` - create directories if they don't already exist.
# `--verbose` - please say what you are actually doing.
rclone bisync $local_todo $cloud_todo --compare modtime --force --backup-dir1 $local_backup --conflict-resolve older --create-empty-src-dirs --verbose
