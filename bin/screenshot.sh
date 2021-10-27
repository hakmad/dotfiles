#!/bin/bash

# Script for taking screenshots.
# 
# The usage of this script is as follows:
# 	screenshot -a, --all		Screenshot the entire screen.
# 	screenshot -w, --window		Screenshot the focused window.
# 
# Screenshots are saved in ~/media/images/screenshots by default.

# Basic variables.
SCREENSHOT_DIR=~/media/images/screenshots/

# Get command line arguments.
while [[ $1 != "" ]]; do
	case $1 in
		-a | --all)
			SCREENSHOT="all"
			;;
		-w | --window)
			SCREENSHOT="window"
			;;
		*)
			exit 1
			;;
	esac
	break
done

# Take screenshot.
if [[ $SCREENSHOT == "all" ]]; then
	FILENAME="$(date "+%Y-%m-%d_%H-%M-%S").png"
	scrot -p $FILENAME
elif [[ $SCREENSHOT == "window" ]]; then
	FILENAME="window_$(date "+%Y-%m-%d_%H-%M-%S").png"
	scrot -u $FILENAME
fi

# Move screenshot to screenshot directory.
mv $FILENAME $SCREENSHOT_DIR

# Create popup.
popup.sh -w 350 -d 5 -m " Screenshot $FILENAME saved"
