#!/bin/bash

# Script for interacting with BSPWM desktops.
# 
# The usage of this script is as follows:
# 	workspace.sh goto [desktop]	Switch to [desktop].
# 	workspace.sh move [desktop]	Move the currently focused node to [desktop].
# 	workspace.sh help		Show this help.
# 
# where [desktop] is the desktop number to go/switch to.

if [[ -z $1 ]]; then
	echo "Invalid arguments supplied! Exiting."
	exit 1
fi

case $1 in
	goto)
		bspc desktop -f "$2"
		popup.sh -m "Workspace $2"
		exit
		;;
	move)
		bspc node -d "$2"
		popup.sh -m "Moved to workspace $2"
		exit
		;;
	help)
		head ${HOME}/.bin/desktop.sh -n 9 | tail -n 7 | sed "s/# //"
		exit
		;;
	*)
		echo "Invalid arguments supplied! Exiting."
		exit 1
		;;
esac
