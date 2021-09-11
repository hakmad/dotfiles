#!/bin/bash

BACKLIGHT=$(xbacklight -get | cut -d "." -f 1)
echo "Backlight is at $BACKLIGHT%"
