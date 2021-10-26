#!/bin/bash

# Script for creating desktop popups with lemonbar.
# 
# The usage of this script is as follows:
# 	popup.sh -d [duration] -w [width] -m [message]
# 
# where:
# 	[duration] is the time (in seconds) for the popup to last
# 	(defaults to 1).
# 	[width] is the width (in pixels) for the popup.
# 	[message] is the message to be shown.

# Get colours and fonts.
source style.sh

# Basic variables.
DURATION=1

# Get command line arguments.
while [[ $1 != "" ]]; do
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
	-F $FOREGROUND -B $BACKGROUND -f "$FONT"
