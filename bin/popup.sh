#!/bin/bash

source style.sh

DURATION=1

WIDTH=500
HEIGHT=30

X=30
Y=30

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



(echo " $MESSAGE"; sleep $DURATION) | lemonbar -d -b \
	-g ${WIDTH}x${HEIGHT}+${X}+${Y} \
	-F "$FOREGROUND" -B "$BACKGROUND" -f "$FONT"
