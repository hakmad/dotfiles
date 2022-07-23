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
	head $HOME/.bin/push-dotfiles.sh -n 10 | tail -n 8 | sed "s/# //"
}

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
	show_help
	exit
fi

# Basic variables.
PACKAGE=$1
ORIGIN="$HOME/.dotfiles/$PACKAGE/"

# Check if necessary files/folders exist.
if [[ -d $ORIGIN ]] && [[ -f $ORIGIN/.location ]]; then
	source $ORIGIN/.location
else
	echo "Necessary files/folders not found, exiting"
	exit 1
fi

# Create directories.
mkdir -p $TARGET

for dir in $(find $ORIGIN -mindepth 1 -type d); do
	dir=${dir##$ORIGIN}
	mkdir -p $TARGET$dir
	echo "Created directory $TARGETS$dir"
done

# Push dotfiles (link or copy - depends on filesystem).
for file in $(find $ORIGIN -mindepth 1 -type f -not -name .location); do
	file=${file##$ORIGIN}

	if ln -s -f $ORIGIN$file $TARGET$file ; then
		echo "Linked $ORIGIN$file -> $TARGET$file"
	elif sudo ln -s -f $ORIGIN$file $TARGET$file ; then
		echo "Linked $ORIGIN$file -> $TARGET$file (using sudo)"
	elif sudo cp $ORIGIN$file $TARGET$file ; then
		echo "Copied $ORIGIN$file -> $TARGET$file (using sudo)"
	else
		echo "Failed to push $ORIGIN$item -> $TARGET$file"
	fi
done

# Push the dotfiles.
echo "Pushed dotfiles for $PACKAGE"
