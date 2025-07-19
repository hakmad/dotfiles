#!/bin/bash

# Set variables for local and cloud todo locations.
local_todo="$HOME/todo/"
cloud_todo="fastmail:todo"

# Download file from the cloud (skip if the local version is newer than the
# cloud version).
rclone sync $cloud_todo $local_todo --update -v

# Upload local file to the the cloud (skip if the cloud version is newer than
# the local version).
rclone sync $local_todo $cloud_todo --update -v
