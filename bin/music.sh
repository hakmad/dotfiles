#!/bin/bash

# Script to download M4A files with youtube-dl and move them to a location.
# 
# The usage of this script is as follows:
# 	music.sh

# Stop the script if there are errors.
set -e

# Set downloads directory for music.
DOWNLOADS_DIR="$HOME/media/music/"

# Use `read` to get input variables.
read -rep "URL: " URL
read -rep "Artist: " ARTIST
read -rep "Title: " TITLE

# Download file.
yt-dlp --extract-audio --audio-format m4a --output %\(id\)s.%\(ext\)s "$URL" \
	--postprocessor-args "ffmpeg:-metadata artist=\"$ARTIST\" -metadata title=\"$TITLE\"" \
    --no-playlist

# Move file to music directory.
mkdir -p "$DOWNLOADS_DIR"
mv -- *.m4a "$DOWNLOADS_DIR"

echo "Successfully downloaded track using youtube-dl."
