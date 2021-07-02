#!/bin/bash

# Script to open the notes for a particular university module.

# Source style.sh for colours and fonts.
. style.sh

# Set module directory and create empty string for list of modules.
MODULE_DIRECTORY=~/workspace/notes/university-modules/
MODULE_LIST=""

# For module is module directory...
for module in $MODULE_DIRECTORY/*/ ; do
	# Add module to module directory list
	module=${module/$MODULE_DIRECTORY\//}
	MODULE_LIST="$MODULE_LIST$module\n"
done

# Run dmenu with module directory list and get the choice.
CHOICE=$(echo -e $MODULE_LIST | dmenu -fn $FONT -nb "$BACKGROUND" -nf \
	"$ACCENT" -sb "$BACKGROUND" -sf "$FOREGROUND" \
	-b -x $X -y $Y -w $WIDTH -h $HEIGHT -s 0)

# If the choice variable is empty...
if [[ -z $CHOICE ]]; then
	exit
else
	cd $MODULE_DIRECTORY$CHOICE
	term --command vim notes.tex &
	sleep 0.1
	doc "notes.pdf" &
fi
