#!/bin/bash

source style.sh

OPTIONS="discord\nfirefox\nobs\nterm\nterm-floating\nqutebrowser\nvirtualbox"

echo -e $OPTIONS | dmenu -fn $FONT -nb $BACKGROUND -nf $ACCENT \
	-sb  $BACKGROUND -sf $FOREGROUND \
	-b -x $X -y $Y -w $WIDTH -h $HEIGHT -s 0 | $SHELL &
