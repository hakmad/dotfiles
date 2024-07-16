#!/bin/bash

# Script for backing up media from my phone.
# Note: this script must be edited depending on the specific use case.

for file in *; do
	if [[ $file == $(basename $0) ]]; then
		:
	else
		extension="${file##*.}"

		# For regular/DCIM media.
		#new_filename="${file:0:10}_${file:11:8}.$extension"

		# For Instagram media.
		#temp="${file#IMG_}"
		#new_filename="${temp:0:4}-${temp:4:2}-${temp:6:5}-${temp:11:2}-${temp:13:2}.$extension"

		# For WhatsApp media.
		#temp="${file#IMG-}"
		#temp="${temp#VID-}"
		#temp="${temp//-WA/_}"
		#new_filename="${temp:0:4}-${temp:4:2}-${temp:6:2}${temp:8}"

		# For screenshots.
		#temp="${file%_*}"
		#temp="${temp#Screenshot_}"
		#new_filename="${temp:0:4}-${temp:4:2}-${temp:6:2}_${temp:9:2}-${temp:11:2}-${temp:13:2}.$extension"

		#echo "$new_filename"
		#echo "$file -> $new_filename"
		#mv $file $new_filename
	fi
done
