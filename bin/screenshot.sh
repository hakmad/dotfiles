#!/bin/bash

# Script for taking screenshots.
# 
# The usage of this script is as follows:
# 	screenshot.sh all	    Screenshot the entire screen.
# 	screenshot.sh window	    Screenshot the focused window.
# 	screenshot.sh selection     Screenshot based on selection.
# 	screenshot.sh help	    Show this help.
# 
# Screenshots are saved in ~/media/images/screenshots by default.

# Basic variables.
SCREENSHOT_DIR="$HOME/media/images/screenshots/"

# Create screenshot directory if it doesn't exist.
mkdir -p $SCREENSHOT_DIR

# If no argument supplied, exit.
if [[ -z $1 ]]; then
	echo "Invalid arguments supplied! Exiting."
	exit 1
fi

# Check arguments and take screenshot.
case $1 in
	all)
		FILENAME="$(date "+%Y-%m-%d_%H-%M-%S").jpg"
		scrot -p "$FILENAME" -q 100 -z
		;;
	window)
		FILENAME="window_$(date "+%Y-%m-%d_%H-%M-%S").jpg"
		scrot -u "$FILENAME" -q 100 -z
		;;
    selection)
        FILENAME="selection_$(date "+%Y-%m-%d_%H-%M-%S").jpg"
        scrot -s "$FILENAME" -q 100 -z
        ;;
	help)
		head $HOME/.bin/screenshot.sh -n 11 | tail -n 9 | sed 's/# //g'
		exit
		;;
	*)
		echo "Invalid arguments supplied! Exiting."
		exit 1
		;;
esac

# Move screenshot to screenshot directory.
mv "$FILENAME" "$SCREENSHOT_DIR"

# Create popup.
popup.sh -d 5 -m "Screenshot $FILENAME saved"
