#!/bin/bash

# Script containing various definitions for fonts, colours and other things.

# Font.
FONT="Fixed-12"

# Colours.
COLOUR0="#101010"
COLOUR1="#7c7c7c"
COLOUR2="#8e8e8e"
COLOUR3="#a0a0a0"
COLOUR4="#686868"
COLOUR5="#747474"
COLOUR6="#868686"
COLOUR7="#b9b9b9"
COLOUR8="#525252"
COLOUR9="#7c7c7c"
COLOUR10="#8e8e8e"
COLOUR11="#a0a0a0"
COLOUR12="#686868"
COLOUR13="#747474"
COLOUR14="#868686"
COLOUR15="#f7f7f7"

# Common colours.
BACKGROUND=$COLOUR0
FOREGROUND=$COLOUR7
ACCENT=$COLOUR8

# Position for small windows.
X=20
Y=20

# Size of small windows.
WIDTH=500
HEIGHT=25

# Size of the screen.
SCREEN_WIDTH=$(xdpyinfo | grep "dimensions" | awk '{print $2}' | \
	cut -d "x" -f 1)
SCREEN_HEIGHT=$(xdpyinfo | grep "dimensions" | awk '{print $2}' | \
	cut -d "x" -f 2)
