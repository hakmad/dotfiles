#!/bin/bash

source style.sh

OPTIONS="alacritty\ndiscord\nfirefox\nobs\nqutebrowser\nvirtualbox"

echo -e $OPTIONS | dmenu -fn $FONT -nb $BACKGROUND -nf $ACCENT \
	-sb  $BACKGROUND -sf $FOREGROUND \
	-b -x $X -y $Y -w $WIDTH -h $HEIGHT -s 0 | $SHELL &
