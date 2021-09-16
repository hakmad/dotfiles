#!/bin/bash

DOWNLOADS_DIR=~/downloads/.aur/
mkdir -p $DOWNLOADS_DIR

clean() {
	cd $DOWNLOADS_DIR
	rm -rf *
	cd -
}

install() {
	PACKAGE=$1

	git clone https://aur.archlinux.org/$PACKAGE $DOWNLOADS_DIR$PACKAGE

	cd $DOWNLOADS_DIR$PACKAGE
	makepkg -si
	cd -
}

while [[ $1 != "" ]]; do
	case $1 in
		-c | --clean)
			clean
			exit
			;;
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
