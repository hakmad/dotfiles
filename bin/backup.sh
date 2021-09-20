#!/bin/bash

VERBOSE=false
BACKUP_DIR=~/.backup
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

if [[ $VERBOSE ]]; then
	log() {
		echo "$@"
	}
else
	log() {
		:
	}
fi

log "Creating backup directory..."
rm -rf $BACKUP_DIR
mkdir -p $BACKUP_DIR
cd $BACKUP_DIR

log "Copying files..."
cp -r ~/.dotfiles ./dotfiles
cp -r ~/downloads .
cp -r ~/media .
cp -r ~/workspace .

log "Creating $FILENAME..."
if [[ $VERBOSE ]]; then
	tar -czvf $FILENAME *
else
	tar -czf $FILENAME
fi

log "Moving $FILENAME to home directory..."
mv $FILENAME ~/

log "Cleaning up..."
rm -rf $BACKUP_DIR
cd -

echo "Successfully created backup file $FILENAME"
