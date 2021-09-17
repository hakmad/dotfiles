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
			install $PACKAGE
			exit
			;;
		-s | --search)
			shift
			PACKAGE=$1
			search $PACKAGE
			exit
			;;
		*)
			exit 1
			;;
	esac
	break
done
