#!/bin/bash

# Script for opening notes for a specific module.

# Get colours and fonts.
source style.sh

# Basic variables.
MODULES_LOCATION=~/workspace/university/
MODULES_LIST_FULLPATH=$(find $MODULES_LOCATION* -maxdepth 0 -type d -not -name template)
MODULES_LIST=""

# Add modules to list for dmenu.
for module in $MODULES_LIST_FULLPATH; do
	module=$(echo $module | cut -d "/" -f 6)
	MODULE_LIST="$MODULE_LIST$module\n"
done

# Run dmenu and get choice.
CHOICE=$(echo -e $MODULE_LIST | dmenu -fn $FONT -nb $BACKGROUND -nf \
	$ACCENT -sb $BACKGROUND -sf $FOREGROUND \
	-b -x $X -y $Y -w $WIDTH -h $HEIGHT -s 0 -q)

# Open notes.
if [[ -z $CHOICE ]]; then
	exit
else
	RESULT=$(find $MODULES_LOCATION -type d -name $CHOICE)
	cd $RESULT/notes
	alacritty --command vim notes.tex &
	sleep 0.1
	zathura --fork notes.pdf &
fi
