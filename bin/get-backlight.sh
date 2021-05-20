#!/bin/bash

# Script to output the current backlight levels in a user-friendly manner.

BACKLIGHT=$(xbacklight -get | cut -d "." -f 1)

OUTPUT="Backlight is at $BACKLIGHT%"

echo $OUTPUT
