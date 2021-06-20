#!/bin/bash

# Script to download MP3 files with youtube-dl and move them to a location.
# 
# The usage of this script is as follows:
# 	mp3.sh [URL] [filename]
# 
# where [URL] is the URL of the file and [filename] is the filename of the
# MP3 file.

# Stop the script if there are errors.
set -e

URL=$1
FILENAME=$2

# Download file.
youtube-dl --extract-audio --audio-format mp3\
	--output "$FILENAME".%\(ext\)s $URL

# If on desktop...
if [[ $OSTYPE == "linux-gnu" ]]; then
	# Create directory if it doesn't already exist.
	mkdir -p ~/media/music
	# Move file to ~/media/music.
	mv "$FILENAME".mp3 ~/media/music
# If on mobile (Android).
elif [[ $OSTYPE == "linux-android" ]]; then
	# Create directory if it doesn't already exist.
	mkdir -p ~/storage/music
	# Move file to ~/storage/music.
	mv "$FILENAME".mp3 ~/storage/music
fi

# Exit.
echo "Successfully downloaded $FILENAME using youtube-dl."
exit 0
