#!/bin/bash

DOWNLOADS_DIR=~/downloads/.aur/
mkdir -p $DOWNLOADS_DIR

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
