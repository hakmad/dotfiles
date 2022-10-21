#!/bin/bash

# Script for running desktop applications.

# List of options.
OPTIONS="alacritty
firefox
discord
keepassxc
obs
pavucontrol
qutebrowser
syncthing
via-ui
wireshark"

# Run dmenu with options and run selected option in the shell.
echo -e "$OPTIONS" | menu.sh | $SHELL &
