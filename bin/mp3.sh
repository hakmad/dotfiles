#!/bin/bash

# Script to download MP3 files with youtube-dl and move them to a location.
# 
# The usage of this script is as follows:
# 	mp3.sh [URL] [artist] [title]
# 
# where [URL] is the URL and [artist]/[title] are the relevant tags to apply.
# The file is saved as [artist]-[title].mp3.

# Stop the script if there are errors.
set -e

# Basic variables.
URL=$1
ARTIST=$2
TITLE=$3
FILENAME=$ARTIST-$TITLE

# Download file.
youtube-dl --extract-audio --audio-format mp3 \
	--output "$FILENAME".%\(ext\)s $URL \
	--postprocessor-args "-metadata artist=\"$ARTIST\" title=\"$TITLE\""

# Find music directory.
if [[ -z $ANDROID_ROOT ]]; then
	DOWNLOADS_DIR=~/media/music/
else
	DOWNLOADS_DIR=~/storage/music/
fi

# Move file to music directory.
mkdir -p $DOWNLOADS_DIR
mv "$FILENAME".mp3 $DOWNLOADS_DIR

echo "Successfully downloaed $FILENAME using youtube-dl"
