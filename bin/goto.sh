#!/bin/bash

# Script for going to a specific workspace.

# Go to workspace.
bspc desktop -f "$@"

# Create popup displaying current workspace.
popup.sh -w 100 -m " Workspace ${@#?}"
