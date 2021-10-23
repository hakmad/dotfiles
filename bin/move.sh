#!/bin/bash

# Script for moving a node to a desktop.
# 
# Usage of this script is as follows:
# 	move.sh [desktop] - move currently focused node to [desktop].
# 
# where [desktop] is the name of the desktop to move to.

bspc node -d "$@"
popup.sh -w 150 -m " Moved to workspace ${@#?}"
