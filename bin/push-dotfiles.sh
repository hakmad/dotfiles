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
	head ~/.bin/push-dotfiles.sh -n 10 | tail -n 8 | sed "s/# //"
}

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
	show_help
	exit
fi

# Basic variables.
NAME=$1
ORIGIN=~/.dotfiles/$NAME/

# Check if necessary files/folders exist.
if [[ -d $ORIGIN ]] && [[ -f $ORIGIN/.location ]]; then
	TARGET=$(cat $ORIGIN/.location)

	# Check if on Android (Termux).
	if [[ -z $ANDROID_ROOT ]]; then
		:
	else
		TARGET="${TARGET/\/home\/hakmad/\
\/data\/data\/com.termux\/files\/home}"
	fi
else
	echo "Necessary files/folders not found, exiting"
	exit 1
fi

# Recursive push function.
push() {
	local ORIGIN=$1
	local TARGET=$2

	mkdir -p $TARGET

	for item in $(ls $ORIGIN); do
		if [[ -d $ORIGIN$item ]]; then
			push $ORIGIN$item/ $TARGET$item/
		else
			if ln -s -f $ORIGIN$item $TARGET$item ; then
				echo "Linked $ORIGIN$item to $TARGET$item"
			elif sudo ln -s -f $ORIGIN$item $TARGET$item ; then
				echo "Linked $ORIGIN$item to $TARGET$item with sudo"
			elif sudo cp $ORIGIN$item $TARGET$item ; then
				echo "Copied $ORIGIN$item to $TARGET$item"
			else
				echo "Failed to push $ORIGIN$item to \
$TARGET$item"
			fi
		fi
	done
}

# Push the dotfiles.
push $ORIGIN $TARGET
echo "Pushed dotfiles for $NAME"
