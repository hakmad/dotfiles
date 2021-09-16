#!/bin/bash

DOWNLOADS_DIR=~/downloads/.aur/
mkdir -p $DOWNLOADS_DIR

install() {
	PACKAGE=$1

	git clone https://aur.archlinux.org/$PACKAGE $DOWNLOADS_DIR$PACKAGE

	cd $DOWNLOADS_DIR$PACKAGE
	makepkg -si
	cd -
}

while [[ $1 != "" ]]; do
	case $1 in
		-i | --install)
			shift
			PACKAGE=$1
			install $PACKAGE
			exit
			;;
		*)
			exit 1
			;;
	esac
	break
done
