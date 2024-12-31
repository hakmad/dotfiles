#!/bin/bash

# Set variables for local and cloud password locations.
local_passwords="$HOME/.passwords/"
cloud_passwords="fastmail:passwords"

# Download file from the cloud (skip if the local version is newer than the
# cloud version).
rclone sync $cloud_passwords $local_passwords --update

# Upload local file to the the cloud (skip if the cloud version is newer than
# the local version
rclone sync $local_passwords $cloud_passwords --update
