#!/bin/bash

# Script for running desktop applications.

# Location of file containing desktop applications.
APPLICATION_LIST="$HOME/.desktop-applications"

# Run dmenu with list of applications and run selected option in the shell.
menu.sh < "$APPLICATION_LIST" | $SHELL &
