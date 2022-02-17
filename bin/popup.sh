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
#
# If a width isn't supplied, the width of the popup is automatically
# calculated based on the length of the message.

# Get colours and fonts.
source style.sh

# Basic variables.
DURATION=1
MESSAGE="  "

# MESSAGE needs to be prefixed with 2 empty spaces for padding
# (otherwise it looks a bit odd).

# Get command line arguments.
while [[ $1 != "" ]]; do
	case $1 in
		-w)
			shift
			WIDTH=$1
			WIDTH_SET=true
			;;
		-d)
			shift
			DURATION=$1
			;;
		-m)
			shift
			MESSAGE+=$1
			;;
	esac
	shift
done

# Set width according to length of message to display.
if [[ ! $WIDTH_SET ]]; then
	# Don't ask how I know these numbers are correct.
	WIDTH=$((14 + 6 * ${#MESSAGE}))
fi

# Run popup.
(echo "$MESSAGE"; sleep $DURATION) | lemonbar -d -b \
	-g ${WIDTH}x${HEIGHT}+${X}+${Y} \
	-F $FOREGROUND -B $BACKGROUND -f "$FONT"
