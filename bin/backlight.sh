#!/bin/bash

# Script for setting/getting backlight information.
# 
# The usage of this script is as follows:
# 	backlight.sh current		Get current backlight level.
# 	backlight.sh increase		Increase backlight.
# 	backlight.sh decrease		Decrease backlight.
# 	backlight.sh help		Show this help.

# Amount to increase/decrease light by.
STEP=5

# If no arguments supplied, exit.
if [[ -z $1 ]]; then
	echo "Invalid arguments supplied! Exiting."
	exit 1
fi

# Check arguments and perform action.
case $1 in
	current)
        echo "$(brightnessctl | grep "Current" | awk '{ print $4 }' | sed 's/[)(]//g')"
		exit
		;;
	increase)
		brightnessctl set "+$STEP%"
		exit
		;;
	decrease)
		brightnessctl set "$STEP-%"
		exit
		;;
	help)
		head ${HOME}/.bin/backlight.sh -n 9 | tail -n 7 | sed "s/# //g"
		exit
		;;
	*)
		echo "Invalid arguments supplied! Exiting."
		exit 1
		;;
esac
