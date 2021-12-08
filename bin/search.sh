#!/bin/bash

# Script for searching for things with qutebrowser using dmenu.

# Get colours and fonts.
source style.sh

# Run dmenu and get search term.
SEARCH_TERM=$(dmenu -fn $FONT -nb $BACKGROUND -nf $FOREGROUND \
	-b -x $X -y $Y -w $WIDTH -h $HEIGHT -s 0 -q -noinput)

# Run qutebrowser with search term.
qutebrowser $SEARCH_TERM &
