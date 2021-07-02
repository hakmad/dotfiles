#!/bin/bash

# Script to run desktop programs using dmenu.

# Source style.sh for colours and fonts.
. style.sh

# Different desktop programs to select from.
OPTIONS="blender\ndiscord\ndoc\nfirefox\ngodot\nobs\
	\nterm\nqutebrowser\nvirtualbox"

# Echo different options and pipe to dmenu, then run the selected option
# using the shell.
echo -e $OPTIONS | dmenu -fn $FONT -nb "$BACKGROUND" -nf "$ACCENT"\
	-sb "$BACKGROUND" -sf "$FOREGROUND" \
	-b -x $X -y $Y -w $WIDTH -h $HEIGHT -s 0 | $SHELL &

# Exit.
exit 0
