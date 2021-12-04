#!/bin/bash

# Script getting a PAT (for git).

# Get colours and fonts.
source style.sh

# Basic variables.
PAT_LOCATION=~/.pat/
PAT_LIST_FULLPATH=$(find $PAT_LOCATION -type f)
PAT_LIST=""

# Add file names to list for dmenu.
for file in $PAT_LIST_FULLPATH; do
	file=$(echo $file | sed "s:.*/::")
	PAT_LIST="$PAT_LIST$file\n"
done

# Run dmenu and get choice.
CHOICE=$(echo -e $PAT_LIST | dmenu -fn $FONT -nb $BACKGROUND -nf \
	$ACCENT -sb $BACKGROUND -sf $FOREGROUND \
	-b -x $X -y $Y -w $WIDTH -h $HEIGHT -s 0)

# Get PAT and copy to clipboard.
if [[ -z $CHOICE ]]; then
	exit
else
	RESULT=$(find $PAT_LOCATION -name $CHOICE)
	cat $RESULT | xsel -i &
fi
