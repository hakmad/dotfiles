#!/bin/bash

# Script for pushing dotfiles to their location.
# 
# The usage of this script is as follows:
# 	push-dotfiles.sh [package]
# 
# where [package] is the name of a directory in ~/.dotfiles.
# It contains a file called .location which specifies where
# the dotfiles should be pushed to.

show_help() {
	head "$HOME/.bin/push-dotfiles.sh" -n 10 | tail -n 8 | sed "s/# //"
}

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
	show_help
	exit
fi

# Basic variables.
PACKAGE=$1
ORIGIN="$HOME/.dotfiles/$PACKAGE/"

# Check if necessary files/folders exist.
if [[ -d $ORIGIN ]] && [[ -f "$ORIGIN/.location" ]]; then
	source "$ORIGIN/.location"
else
	echo "Necessary files/folders not found, exiting"
	exit 1
fi

# Create directories.
$RUN_AS mkdir -p "$TARGET"
echo "Created directory $TARGET"

find "$ORIGIN" -mindepth 1 -type d | while read -r dir; do
	dir=${dir##"$ORIGIN"}
	$RUN_AS mkdir -p "$TARGET$dir"
	echo "Created directory $TARGETS$dir"
done

# Push dotfiles (link or copy - depends on filesystem).
find "$ORIGIN" -mindepth 1 -type f -not -name .location | while read -r file; do
	file=${file##"$ORIGIN"}

	if $RUN_AS ln -s -f "$ORIGIN$file" "$TARGET$file" ; then
		echo "Linked $ORIGIN$file -> $TARGET$file"
	elif $RUN_AS cp "$ORIGIN$file" "$TARGET$file" ; then
		echo "Copied $ORIGIN$file -> $TARGET$file"
	else
		echo "Failed to push $ORIGIN$file -> $TARGET$file"
		exit 1
	fi
done

# Push the dotfiles.
echo "Pushed dotfiles for $PACKAGE"
