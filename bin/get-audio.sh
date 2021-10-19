#!/bin/bash

# Script for outputting audio information.
# 
# The usage of this script is as follows:
# 	get-audio.sh -a, --all		Get all information.
# 	get-audio.sh -v, --volume	Get volume information.
# 	get-audio.sh -s, --status	Get status information.

# Get volume.
return_volume() {
	VOLUME=$(amixer get Master | tail -n 1 | cut -d "[" -f 2 | tr -d "]")
	echo $VOLUME
}

# Get status.
return_status() {
	STATUS=$(amixer get Master | tail -n 1 | cut -d "[" -f 3 | tr -d "]")
	echo $STATUS
}

# Output volume.
output_volume() {
	echo "Audio at $(return_volume)"
}

# Output status.
output_status() {
	echo "Audio is $(return_status)"
}

# Output everything.
output_all() {
	echo "Audio is $(return_status), at $(return_volume)"
}

# Get command line arguments.
while [[ $1 != "" ]]; do
	case $1 in
		-a | --all)
			output_all
			exit
			;;
		-v | --volume)
			output_volume
			exit
			;;
		-s | --status)
			output_status
			exit
			;;
		*)
			exit 1
			;;
	esac
done
