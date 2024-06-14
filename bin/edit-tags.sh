#!/bin/bash

# Script to edit the tags of music files with ffmpeg.
#
# The usage of this script is as follows:
# 	edit-tags.sh [file]

# Stop the script if there are errors.
set -e

# Get file.
FILE=$1

# Use `read` to get input variables.
read -rep "Artist: " ARTIST
read -rep "Title: " TITLE

# Edit tags.
ffmpeg -i $FILE -metadata artist="$ARTIST" -metadata title="$TITLE" temp.m4a

# Rewrite old file.
mv temp.m4a $FILE

# On Android, ask MediaStore to rescan music directory.
if [[ -a $ANDROID_ROOT ]]; then
	termux-media-scan $FILE
fi

echo "Successfully edited tags for $FILE"
