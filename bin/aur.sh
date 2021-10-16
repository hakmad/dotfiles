#!/bin/bash

# Script for installing packages from the AUR.
# 
# The usage of this script is as follows:
# 	aur.sh -i, --install [package]	Install a package.
# 	aur.sh -s, --search [package]	Search for a package.
# 	aur.sh -c, --clean		Remove installation files.
# 	aur.sh -l, --list		List all packages from the AUR.
# 
# where [package] is the name of the package to be installed/searched for.

# Directory for installation files.
DOWNLOADS_DIR=~/downloads/.aur/
mkdir -p $DOWNLOADS_DIR

# Helper function for passing an argument to a function.
argument_handler() {
	FUNCTION=$1
	ARGUMENT=$2

	if [[ -z $ARGUMENT ]]; then
		echo "Argument not supplied, exiting"
		exit 1
	else
		$FUNCTION $ARGUMENT
	fi
}

# Clean download directory.
clean() {
	cd $DOWNLOADS_DIR
	rm -rf *
	cd -
}

# Install a package.
install() {
	PACKAGE=$1

	git clone https://aur.archlinux.org/$PACKAGE $DOWNLOADS_DIR$PACKAGE

	cd $DOWNLOADS_DIR$PACKAGE
	makepkg -si
	cd -
}

# List packages from the AUR.
list() {
	pacman -Qm
}

# Search for a package.
search() {
	PACKAGE=$1

	RESULT=$(curl -s \
		"https://aur.archlinux.org/rpc/?type=search&arg=$PACKAGE" \
		| jq -r ".results | .[] | .Name, .Version, .Description")

	while read PACKAGE; read VERSION; read DESCRIPTION
	do
		echo "aur/$PACKAGE $VERSION"
		echo "    $DESCRIPTION"
	done <<< $RESULT
}

# Get command line arguments.
while [[ $1 != "" ]]; do
	case $1 in
		-c | --clean)
			clean
			exit
			;;
		-i | --install)
			shift
			PACKAGE=$1
			argument_handler install $PACKAGE
			exit
			;;
		-l | --list)
			list
			exit
			;;
		-s | --search)
			shift
			PACKAGE=$1
			argument_handler search $PACKAGE
			exit
			;;
		*)
			exit 1
			;;
	esac
	break
done
