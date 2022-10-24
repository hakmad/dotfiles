#!/bin/bash

# Script for running desktop applications.

# Location of file containing desktop applications.
APPLICATION_LIST=~/.desktop-applications

# Run dmenu with list of applications and run selected option in the shell.
cat $APPLICATION_LIST | menu.sh | $SHELL &
