#!/bin/bash

# Script for taking a screenshot.
# 
# The usage of this script is as follows:
# 	screenshot.sh -a, --all		Take screenshot of the entire screen.
# 	screenshot.sh -s, --single	Take screenshot of the current window.

# Get command line arguments.
while [[ $1 != "" ]]; do
	case $1 in
		-a | --all)
			SCREENSHOT="all"
			;;
		-s | --single)
			SCREENSHOT="single"
			;;
		*)
			exit 1
			;;
	esac
	break
done

if [[ $SCREENSHOT == "all" ]]; then
	# Take screenshot of the entire screen.
	FILENAME="$(date "+%Y-%m-%d_%H-%M-%S").png"
	scrot -p $FILENAME
elif [[ $SCREENSHOT == "single" ]]; then
	# Take screenshot of the current window.
	FILENAME="window_$(date "+%Y-%m-%d_%H-%M-%S").png"
	scrot -u $FILENAME
fi

# Move screenshot to ~/media/images/screenshots.
mv $FILENAME ~/media/images/screenshots

# Create popup to notify user of screenshot.
popup.sh -w 310 -d 5 -m " Screenshot $FILENAME saved"
