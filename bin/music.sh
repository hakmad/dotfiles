#!/bin/bash

# Script to download M4A files with youtube-dl and move them to a location.
# 
# The usage of this script is as follows:
# 	music.sh

# Stop the script if there are errors.
set -e

# Use `read` to get input variables.
read -rep "URL: " URL
read -rep "Artist: " ARTIST
read -rep "Title: " TITLE

# Download file.
yt-dlp --extract-audio --audio-format m4a --output %\(id\)s.%\(ext\)s "$URL" \
	--postprocessor-args "ffmpeg:-metadata artist=\"$ARTIST\" -metadata title=\"$TITLE\""

# Find music directory.
if [[ -z $ANDROID_ROOT ]]; then
	DOWNLOADS_DIR="$HOME/media/music/"
else
	DOWNLOADS_DIR="$HOME/storage/music/"
fi

# Move file to music directory.
mkdir -p "$DOWNLOADS_DIR"
mv -- *.m4a "$DOWNLOADS_DIR"

# On Android, ask MediaStore to rescan music directory.
if [[ -a $ANDROID_ROOT ]]; then
	termux-media-scan "$DOWNLOADS_DIR"
fi

echo "Successfully downloaded track using youtube-dl."
