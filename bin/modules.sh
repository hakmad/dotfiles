#!/bin/bash

source style.sh

MODULES_LOCATION=~/workspace/notes/university-modules/
MODULES_LIST_FULLPATH=$(find $MODULES_LOCATION -mindepth 2 -maxdepth 2 -type d)
MODULES_LIST=""

for module in $MODULES_LIST_FULLPATH; do
	module=$(echo $module | sed "s:.*/::")
	MODULE_LIST="$MODULE_LIST$module\n"
done

CHOICE=$(echo -e $MODULE_LIST | dmenu -fn $FONT -nb "$BACKGROUND" -nf \
	"$ACCENT" -sb "$BACKGROUND" -sf "$FOREGROUND" \
	-b -x $X -y $Y -w $WIDTH -h $HEIGHT -s 0)

if [[ -z $CHOICE ]]; then
	exit
else
	RESULT=$(find $MODULES_LOCATION -type d -name $CHOICE)
	cd $RESULT
	alacritty --command vim notes.tex &
	sleep 0.1
	zathura "notes.pdf" &
fi
