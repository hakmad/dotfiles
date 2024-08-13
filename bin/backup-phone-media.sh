#!/bin/bash

# Script for backing up media from my phone.

edit_filename() {
	echo "$1 -> $2"
	
	$LIVE_RUN && mv $1 $2
}

# Check arguments.
case $1 in
	"live")
		LIVE_RUN=true
		;;
	"safe")
		LIVE_RUN=false
		;;
	*)
		echo "Run with arguments!"
		exit 1
		;;
esac

# Create temporary directory.
mkdir -p $HOME/.tmp/phone-backup/
cd $HOME/.tmp/phone-backup/

# Pull media from phone.
adb pull /storage/self/primary/DCIM/Camera/ camera-roll/
adb pull /storage/self/primary/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp\ Images/ whatsapp-images/
adb pull /storage/self/primary/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp\ Video/ whatsapp-videos/
adb pull /storage/self/primary/Pictures/Screenshots screenshots/

# Crate new directory for WhatsApp media.
mkdir -p whatsapp/
cp whatsapp-images/* whatsapp-videos/* whatsapp/

# Regular/DCIM media.
cd camera-roll/
for file in *; do
	extension="${file##*.}"

	new_filename="${file:0:10}_${file:11:8}.$extension"

	edit_filename $file $new_filename
done
cd ..

# WhatsApp media.
cd whatsapp/
for file in *; do
	extension="${file##*.}"

	temp="${file#IMG-}"
	temp="${temp#VID-}"
	temp="${temp//-WA/_}"
	new_filename="${temp:0:4}-${temp:4:2}-${temp:6:2}${temp:8}"

	edit_filename $file $new_filename
done
cd ..

# Screenshots.
cd screenshots/
for file in *; do
	extension="${file##*.}"

	temp="${file%_*}"
	temp="${temp#Screenshot_}"
	new_filename="${temp:0:4}-${temp:4:2}-${temp:6:2}_${temp:9:2}-${temp:11:2}-${temp:13:2}.$extension"

	edit_filename $file $new_filename
done
cd ..

# Copy media across.
if $LIVE_RUN; then
	cp camera-roll/* $HOME/media/phone/camera-roll/
	cp whatsapp/* $HOME/media/phone/camera-roll/
	cp screenshots/* $HOME/media/phone/screenshots/
fi

# Delete temporary directory.
cd $HOME
rm -rf $HOME/.tmp/phone-backup/

echo "Backup completed. Please check ~/media directory to verify!"
