#!/bin/bash

VERBOSE=false
BACKUPDIR=~/.backup/
CURRENTDIR=$(pwd)
FILENAME="backup.tar.gz"

while [[ $1 != "" ]]; do
	case $1 in
		-v | --verbose)
			VERBOSE=true
			shift
			;;
		-o | --output)
			shift
			FILENAME=$1
			shift
			;;
		*)
			shift
			;;
	esac
done

if [[ $VERBOSE = true ]]; then
	log() {
		echo "$@";
	}
else
	log() {
		:;
	}
fi

log "Creating backup directory..."
rm -rf $BACKUPDIR
mkdir $BACKUPDIR
cd $BACKUPDIR

log "Copying files..."
cp -r ~/.dotfiles ./dotfiles
cp -r ~/downloads .
cp -r ~/media .
cp -r ~/workspace .

log "Creating $FILENAME..."
if [[ $VERBOSE = true ]]; then
	tar -czvf $FILENAME *
else
	tar -czf $FILENAME *
fi

log "Moving $FILENAME to home directory..."
mv $FILENAME ~/

log "Cleaning up..."
cd $CURRENTDIR
rm -rf $BACKUPDIR

echo "Successfully created backup file: $FILENAME."
exit 0
