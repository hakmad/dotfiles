#!/bin/bash

# Script for making desktop popups using lemonbar.
# 
# The usage of this script is as follows:
#	popup.sh -d [duration] -w [width] -m [message]
#
# where [duration] is the time (in seconds) for the popup to stay alive,
# [width] is the width (in pixels) of the popup and [message] is the text
# to be displayed on the popup.

# Source style.sh for colours and fonts.
. style.sh

# Default duration for the popup
DURATION=1

# Get command line arguments.
while [[ "$1" != "" ]]; do
	case $1 in
		-w)
			shift
			WIDTH=$1
			;;
		-d)
			shift
			DURATION=$1
			;;
		-m)
			shift
			MESSAGE=$1
			;;
	esac
	shift
done

# Run popup.
(echo " $MESSAGE"; sleep $DURATION) | lemonbar -d -b \
	-g ${WIDTH}x${HEIGHT}+${X}+${Y} \
	-F "$FOREGROUND" -B "$BACKGROUND" -f $FONT

# Exit.
exit 0
