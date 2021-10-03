#!/bin/bash

NAME=$1
ORIGIN=~/.dotfiles/$NAME/

if [[ -d $ORIGIN ]] && [[ -f $ORIGIN/.location ]]; then
	TARGET=$(cat $ORIGIN/.location)
else
	echo "Necessary files/folders not found, exiting"
	exit 1
fi

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
			elif sudo cp $ORIGIN$item $TARGET$item ; then
				echo "Copied $ORIGIN$item to $TARGET$item"
			else
				echo "Failed to push $ORIGIN$item to \
$TARGET$item"
			fi
		fi
	done
}

push $ORIGIN $TARGET

echo "Pushed dotfiles for $NAME"
