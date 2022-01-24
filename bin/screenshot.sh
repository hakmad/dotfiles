#!/bin/bash

# Script for taking screenshots.
# 
# The usage of this script is as follows:
# 	screenshot.sh -a, --all		Screenshot the entire screen.
# 	screenshot.sh -w, --window	Screenshot the focused window.
# 	screenshot.sh -h, --help	Show this help.
# 
# Screenshots are saved in ~/media/images/screenshots by default.

# Basic variables.
SCREENSHOT_DIR=~/media/images/screenshots/

# Show help.
show_help() {
	head ~/.bin/screenshot.sh -n 10 | tail -n 8 | sed 's/# //g'
}

# Get command line arguments.
while [[ $1 != "" ]]; do
	case $1 in
		-a | --all)
			SCREENSHOT="all"
			;;
		-w | --window)
			SCREENSHOT="window"
			;;
		-h | --help)
			show_help
			exit
			;;
		*)
			exit 1
			;;
	esac
	break
done

# Take screenshot.
if [[ $SCREENSHOT == "all" ]]; then
	FILENAME="$(date "+%Y-%m-%d_%H-%M-%S").jpg"
	scrot -p $FILENAME
elif [[ $SCREENSHOT == "window" ]]; then
	FILENAME="window_$(date "+%Y-%m-%d_%H-%M-%S").jpg"
	scrot -u $FILENAME
fi

# Move screenshot to screenshot directory.
mv $FILENAME $SCREENSHOT_DIR

# Create popup.
popup.sh -w 350 -d 5 -m " Screenshot $FILENAME saved"
