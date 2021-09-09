#!/bin/bash

source style.sh

OPTIONS="discord\nfirefox\nobs\nterm\nterm-floating\nqutebrowser\nvirtualbox"

X=30
Y=30

WIDTH=500
HEIGHT=30

echo -e $OPTIONS | dmenu -fn $FONT -nb $BACKGROUND -nf $ACCENT \
	-sb  $BACKGROUND -sf $FOREGROUND \
	-b -x $X -y $Y -w $WIDTH -h $HEIGHT -s 0 | $SHELL &
