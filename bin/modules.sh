#!/bin/bash

# Script for opening notes for a specific module.

# Get colours and fonts.
source style.sh

# Basic variables.
MODULES_LOCATION=~/workspace/notes/university-modules/
MODULES_LIST_FULLPATH=$(find $MODULES_LOCATION -mindepth 2 -maxdepth 2 -type d)
MODULES_LIST=""

# Add modules to list for dmenu.
for module in $MODULES_LIST_FULLPATH; do
	module=$(echo $module | sed "s:.*/::")
	MODULE_LIST="$MODULE_LIST$module\n"
done

# Run dmenu and get choice.
CHOICE=$(echo -e $MODULE_LIST | dmenu -fn $FONT -nb $BACKGROUND -nf \
	$ACCENT -sb $BACKGROUND -sf $FOREGROUND \
	-b -x $X -y $Y -w $WIDTH -h $HEIGHT -s 0)

# Open notes.
if [[ -z $CHOICE ]]; then
	exit
else
	RESULT=$(find $MODULES_LOCATION -type d -name $CHOICE)
	cd $RESULT
	alacritty --command vim notes.tex &
	sleep 0.1
	zathura --fork notes.pdf &
fi
