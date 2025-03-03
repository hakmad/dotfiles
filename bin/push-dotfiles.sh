#!/bin/bash

# Script for pushing dotfiles to their location.
# 
# The usage of this script is as follows:
# 	push-dotfiles.sh [package] [origin]
# 
# where [package] is the name of a directory containing dotfiles 
# and [origin] is the dotfiles are located (defaults to ~/.dotfiles).
# The directory of the package contains a file named .location which
# specifies where the dotfiles should be pushed to.

show_help() {
	head "$HOME/.bin/push-dotfiles.sh" -n 11 | tail -n 9 | sed "s/# //"
}

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
	show_help
	exit
fi

# Basic variables.
PACKAGE=$1
if [[ -z $2 ]]; then
    ORIGIN="$HOME/.dotfiles/$PACKAGE/"
else
    ORIGIN=$2/$PACKAGE
fi

# Check if necessary files/folders exist.
if [[ -d $ORIGIN ]] && [[ -f "$ORIGIN/.location" ]]; then
	source "$ORIGIN/.location"
else
	echo "Necessary files/folders not found, exiting"
	exit 1
fi

# Create directories.
mkdir -p "$TARGET"
echo "Created directory $TARGET"

find "$ORIGIN" -mindepth 1 -type d | while read -r dir; do
	dir=${dir##"$ORIGIN"}
	mkdir -p "$TARGET$dir"
	echo "Created directory $TARGETS$dir"
done

# Push dotfiles (link or copy - depends on filesystem).
find "$ORIGIN" -mindepth 1 -type f -not -name .location | while read -r file; do
	file=${file##"$ORIGIN"}

	if ln -s -f "$ORIGIN$file" "$TARGET$file" ; then
		echo "Linked $ORIGIN$file -> $TARGET$file"
	elif cp "$ORIGIN$file" "$TARGET$file" ; then
		echo "Copied $ORIGIN$file -> $TARGET$file"
	else
		echo "Failed to push $ORIGIN$file -> $TARGET$file"
		exit 1
	fi
done

# Push the dotfiles.
echo "Pushed dotfiles for $PACKAGE"
