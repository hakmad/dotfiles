#!/bin/bash

# Script for creating menues with dmenu.
# 
# The usage of this script is as follows:
# 	[options] |
# 	menu.sh [flags] |
# 	[handler
# 
# where:
# 	[options] is the different options to be passed to dmenu.
# 	[flags] is any extra flags to be passed to dmenu.
# 	[handler] is whatever is responsible for handling the option
# 	selected by the user (usually Bash, though it is possible to
# 	not have a handler at all).

# Get colours and fonts.
source style.sh

# Pipe our stdin to stdin of dmenu.
cat - | dmenu -fn $FONT -nb $BACKGROUND -nf $ACCENT \
	-sb $BACKGROUND -sf $FOREGROUND -b -x $X -y $Y \
	-w $WIDTH -h $HEIGHT -q "$@"
