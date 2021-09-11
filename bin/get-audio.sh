#!/bin/bash

return_volume() {
	VOLUME=$(amixer get Master | tail -n 1 | cut -d "[" -f 2 | tr -d "]")
	echo $VOLUME
}

return_status() {
	STATUS=$(amixer get Master | tail -n 1 | cut -d "[" -f 3 | tr -d "]")
	echo $STATUS
}

output_volume() {
	echo "Audio at $(return_volume)"
}

output_status() {
	echo "Audio is $(return_status)"
}

output_all() {
	echo "Audio is $(return_status), at $(return_volume)"
}

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
