#!/bin/bash

# Script to push dotfiles to their location.
# 
# The usage of this script is as follows:
# 	push-dotfiles.sh [name]
# 
# where [name] is the name of a folder in ~/.dotfiles. This folder contains 2
# things: the dotfiles themselves and a file called .location which indicates
# where the dotfiles should go.

# Setup argument variables passed to program.
NAME=$1
ORIGIN=~/.dotfiles/$NAME/

# If the files/folder necessary for setup actually exist...
if [[ (-d $ORIGIN) && (-f $ORIGIN/.location) ]]; then
	TARGET=$(cat $ORIGIN/.location)
	# If not on Android (Termux)...
	if [[ -z $ANDROID_ROOT ]]; then
		# Do nothing.
		:
	else
		# Change path from /home/hakmad/[location] to
		# /data/data/com.termux/files/home.
		TARGET="${TARGET/\/home\/hakmad/\
\/data\/data\/com.termux\/files\/home}"
	fi
else
	echo "Necessary files/folders not found, exiting"
	exit 1
fi

# Function to actually push dotfiles.
push () {
	# Setup variables local to the function.
	local ORIGIN=$1
	local TARGET=$2

	# Makde target directory.
	mkdir -p $TARGET

	# For item in the origin directory...
	for item in $(ls $ORIGIN); do
		# If the item is a directory...
		if [[ -d $ORIGIN$item ]]; then
			# Recurse into that directory.
			push $ORIGIN$item/ $TARGET$item/
		else
			# Attempt to make a symbolic link between the original
			# file and the target directory
			if ln -s -f $ORIGIN$item $TARGET$item ; then
				echo "Linked $ORIGIN$item to $TARGET$item"
			# Attempt to copy the original file to the target
			# directory.
			elif sudo cp $ORIGIN$item $TARGET$item ; then
				echo "Copied $ORIGIN$item to $TARGET$item"
			# Report failure
			else
				echo "Failed to push $ORIGIN$item to \
$TARGET$item"
			fi
		fi
	done
}

# Start the process.
push $ORIGIN $TARGET

# Exit.
echo "Pushed dotfiles for $NAME"
exit 0
