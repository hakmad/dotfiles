#!/bin/bash

for file in *; do
	ext="$(echo ${file##*.} | tr 'A-Z' 'a-z')"

	case $ext in
		"jpg")
			date="$(file $file | awk '{print $20}' | sed 's/datetime=//' | sed 's/:/-/g')"
			time="$(file $file | awk '{print $21}' | sed 's/],//' | sed 's/:/-/g')"
			;;
		"mov")
			date="$(mediainfo $file | grep "date" | head -n 1 | awk '{print $4}')"
			time="$(mediainfo $file | grep "date" | head -n 1 | awk '{print $5}' | tr ':' '-')"
			;;
		*)
			echo "Unknown extension! Exiting."
			exit 1
			;;
	esac

	new_filename="${date}_${time}.$ext"

	echo "$file -> $new_filename"
	mv $file $new_filename
done
