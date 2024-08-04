#!/bin/bash

# Script for interacting with BSPWM desktops.
# 
# The usage of this script is as follows:
# 	desktop.sh goto [desktop]	Switch to [desktop].
# 	desktop.sh move [desktop]	Move the currently focused node to [desktop].
# 	desktop.sh current		List the currently focused desktop.
# 	desktop.sh help			Show this help.
# 
# where [desktop] is the desktop number to go/switch to.

# If no argument supplied, exit.
if [[ -z $1 ]]; then
	echo "Invalid arguments supplied! Exiting."
	exit 1
fi

# Check arguments and perform action.
case $1 in
	goto)
		bspc desktop -f "$2"
		popup.sh -m "Desktop $2" -p "popup_desktop" -k "popup_*"
		exit
		;;
	move)
		bspc node -d "$2"
		popup.sh -m "Moved to desktop $2" -p "popup_desktop" -k "popup_*"
		exit
		;;
	current)
		popup.sh -m "Desktop $(bspc query -D -d focused --names)" -p "popup_desktop" -k "popup_*"
		exit
		;;
	help)
		head ${HOME}/.bin/desktop.sh -n 11 | tail -n 9 | sed "s/# //"
		exit
		;;
	*)
		echo "Invalid arguments supplied! Exiting."
		exit 1
		;;
esac
