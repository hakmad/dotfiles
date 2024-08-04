#!/bin/bash

# Script for creating desktop popups with lemonbar.
# 
# The usage of this script is as follows:
# 	popup.sh -d [duration] -w [width] -m [message] -y [Y location]
# 
# where:
# 	[duration] is the time (in seconds) for the popup to last
# 	(defaults to 1).
# 	[width] is the width (in pixels) for the popup.
# 	[message] is the message to be shown.
# 	[Y location] is the Y location relative to the bottom of the screen.
#
# If a width isn't supplied, the width of the popup is automatically
# calculated based on the length of the message.

# Get colours and fonts.
source style.sh

# Basic variables.
DURATION=1
MESSAGE=" "
PROCESS_LOCATION="/tmp/popups/"
PROCESS_NAME=""
KILL_PROCESSES=false
PROCESSES_TO_KILL=""

# MESSAGE needs to be prefixed with an empty space for padding
# (otherwise it looks a bit odd).

# Create location for popups directory.
mkdir -p $PROCESS_LOCATION

# Get command line arguments.
while [[ $1 != "" ]]; do
	case $1 in
		-w | --width)
			shift
			WIDTH=$1
			WIDTH_SET=true
			;;
		-d | --duration)
			shift
			DURATION=$1
			;;
		-m | --message)
			shift
			MESSAGE+=$1
			;;
		-y | --y-location)
			shift
			Y=$1
			;;
		-p | --process-name)
			shift
			PROCESS_NAME=$1
			;;
		-k | --kill-processes)
			shift
			PROCESSES_TO_KILL=$1
			KILL_PROCESSES=true
			;;
	esac
	shift
done

# Set width according to length of message to display.
if [[ ! $WIDTH_SET ]]; then
	# Don't ask how I know these numbers are correct.
	WIDTH=$((7 + 7 * ${#MESSAGE}))
fi

# Move popup to the left of the screen.
X=$((SCREEN_WIDTH-X-WIDTH))

# Kill previous processes.
if [[ $PROCESS_NAME != "" ]]; then
	kill -9 $(< $PROCESS_LOCATION$PROCESS_NAME)
fi

# Kill other processes.
if [[ $KILL_PROCESSES ]]; then
	# Iterate through each PID file (may give process names as a wildcard).
	for pid_file in $PROCESS_LOCATION$PROCESSES_TO_KILL; do
		kill -9 $(< $pid_file)
	done
fi

# Run popup.
(echo "$MESSAGE"; sleep "$DURATION") | lemonbar -d -b \
	-g ${WIDTH}x${HEIGHT}+${X}+${Y} \
	-F $FOREGROUND -B $BACKGROUND -f "$FONT" -o 1 &
	[[ $PROCESS_NAME != "" ]] && echo "$!" > "$PROCESS_LOCATION$PROCESS_NAME" 
