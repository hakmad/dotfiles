#!/bin/bash

# Script to download MP3 files with youtube-dl and move them to a location.
# 
# The usage of this script is as follows:
# 	mp3.sh [URL] [filename]
# 
# where [URL] is the URL and [filename] is the name of the file to save.

# Basic variables.
URL=$1
FILENAME=$2

# Download file.
youtube-dl --extract-audio --audio-format mp3 \
	--output "$FILENAME".%\(ext\)s $URL

# Find music directory.
if [[ -z $ANDROID_ROOT ]]; then
	DOWNLOADS_DIR=~/media/music/
else
	DOWNLOADS_DIR=~/storage/music
fi

# Move file to music directory.
mkdir -p $DOWNLOADS_DIR
mv "$FILENAME".mp3 $DOWNLOADS_DIR

echo "Successfully downloaed $FILENAME using youtube-dl"
