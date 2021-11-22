#!/bin/bash

# Script for running desktop applications.

# Get colours and fonts.
source style.sh

# List of options.
OPTIONS="alacritty
firefox
obs
pavucontrol
qutebrowser
via-ui
wireshark"

# Run dmenu with options and run selected option in the shell.
echo -e "$OPTIONS" | dmenu -fn $FONT -nb $BACKGROUND -nf $ACCENT \
	-sb  $BACKGROUND -sf $FOREGROUND \
	-b -x $X -y $Y -w $WIDTH -h $HEIGHT -s 0 -q | $SHELL &
