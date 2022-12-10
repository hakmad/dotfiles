#!/bin/bash

# Script for setting/getting audio levels.
# 
# The usage of this script is as follows:
# 	audio.sh volume		Get volume.
# 	audio.sh status		Get mute status.
# 	audio.sh increase	Increase volume.
# 	audio.sh decrease	Decrease volume.
# 	audio.sh toggle 	Toggle audio mute.
# 	audio.sh help		Show this help.

# Amount to increase/decrease volume by.
STEP=2

# If no arguments supplied, exit.
if [[ -z $1 ]]; then
	echo "Invalid arguments supplied! Exiting."
	exit 1
fi

# Check arguments and perform action.
case $1 in
	volume)
		echo $(amixer get Master | tail -n 1 | cut -d "[" -f 2 | tr -d "]")
		exit
		;;
	status)
		echo $(amixer get Master | tail -n 1 | cut -d "[" -f 3 | tr -d "]" | sed "s/.*/\u&/")
		exit
		;;
	increase)
		amixer set Master $STEP%+ > /dev/null
		exit
		;;
	decrease)
		amixer set Master $STEP%- > /dev/null
		exit
		;;
	toggle)
		amixer set Master toggle > /dev/null
		exit
		;;
	help)
		head ${HOME}/.bin/audio.sh -n 11 | tail -n 9 | sed "s/# //g"
		exit
		;;
	*)
		echo "Invalid arguments supplied! Exiting."
		exit 1
esac
