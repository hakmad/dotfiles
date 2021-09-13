#!/bin/bash

while [[ $1 != "" ]]; do
	case $1 in
		-a | --all)
			SCREENSHOT="all"
			;;
		-w | --window)
			SCREENSHOT="window"
			;;
		*)
			exit 1
			;;
	esac
	break
done

if [[ $SCREENSHOT == "all" ]]; then
	FILENAME="$(date "+%Y-%m-%d_%H-%M-%S").png"
	scrot -p $FILENAME
elif [[ $SCREENSHOT == "window" ]]; then
	FILENAME="window_$(date "+%Y-%m-%d_%H-%M-%S").png"
	scrot -u $FILENAME
fi

mv $FILENAME ~/media/images/screenshots

popup.sh -w 350 -d 5 -m " Screenshot $FILENAME saved"
