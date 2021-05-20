#!/bin/bash

# Script to output the current audio information in a user-friendly manner.
# 
# The usage of the script is as follows:
# 	get-audio.sh -a, --all		Output all audio information.
# 	get-audio.sh -s, --status	Output volume mute status.
# 	get-audio.sh -v, --volume	Output volume level.

output_all() {
	VOLUME=$(amixer get Master | tail -n 1 | cut -d "[" -f 2 | \
		sed "s/]//g")
	STATUS=$(amixer get Master | tail -n 1 | cut -d "[" -f 3 | \
		sed "s/]//g")

	OUTPUT="Volume is $STATUS, at $VOLUME"
	echo $OUTPUT
}

output_status() {
	STATUS=$(amixer get Master | tail -n 1 | cut -d "[" -f 3 | \
		sed "s/]//g")

	OUTPUT="Volume is $STATUS"
	echo $OUTPUT
}

output_volume() {
	VOLUME=$(amixer get Master | tail -n 1 | cut -d "[" -f 2 | \
		sed "s/]//g")

	OUTPUT="Volume at $VOLUME"
	echo $OUTPUT
}

# Get command line arguments.
while [[ $1 != "" ]]; do
	case $1 in
		-a | --all)
			output_all
			exit
			;;
		-s | --status)
			output_status
			exit
			;;
		-v | --volume)
			output_volume
			exit
			;;
		* )
			exit 1
			;;
	esac
done
