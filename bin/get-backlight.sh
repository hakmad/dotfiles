#!/bin/bash

# Script for outputting backlight information.
# 
# The usage of this script is as follows:
# 	get-backlight.sh

BACKLIGHT=$(light -G | cut -d "." -f 1)
echo "Backlight is at $BACKLIGHT%"
