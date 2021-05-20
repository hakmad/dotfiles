#!/bin/bash

# Script for getting system information. Output from this script is designed
# to be used with lemonbar.

# Source style.sh for colours and fonts.
. style.sh

# Get workspaces from BSPWM.
workspaces() {
	START=2
	END=6
	# For workspace in output from bspc...
	for i in `seq $START $END` ; do
		WORKSPACE=$(bspc wm -g | cut -d ":" -f $i)
		case $WORKSPACE in
			# If workspace is focused...
			[FOU]*)
				WORKSPACE="${WORKSPACE:1}"
				echo "$WORKSPACE"
				;;
			# If workspace is not focused...
			[fou]*)
				WORKSPACE="${WORKSPACE:1}"
				echo "%{F$ACCENT}$WORKSPACE%{F-}"
				;;
		esac
	done
}

# Get the date and time.
clock() {
	DATE=$(date "+%a %d/%m/%Y")
	TIME=$(date "+%H:%M")

	echo "%{F$ACCENT} DATE%{F-} $DATE"
	echo "%{F$ACCENT} TIME%{F-} $TIME"
}

# Get audio information.
audio() {
	VOLUME_STATUS=$(amixer get Master | tail -n 1 | cut -d "[" -f 3 |\
		sed "s/].*//g")
	VOLUME_LEVEL=$(amixer get Master | tail -n 1 | cut -d "[" -f 2 |\
		sed "s/].*//g")

	# If volume is not muted...
	if [[ "$VOLUME_STATUS" == "on" ]] ; then
		echo "%{F$ACCENT} VOLUME%{F-} $VOLUME_LEVEL"
	else
		echo "%{F$ACCENT} VOLUME%{F-} Muted"
	fi
}

# Output information.
while true; do
	OUTPUT="\v %{l} $(workspaces) %{c} $(clock) %{r} $(audio) \v"
	echo -e $OUTPUT
	sleep 0.1
done

# Exit.
exit 0
