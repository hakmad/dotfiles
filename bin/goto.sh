#!/bin/bash

# Script for going to a desktop.
# 
# Usage of this script is as follows:
# 	goto.sh [desktop] - go to [desktop].
# 
# where [desktop] is the name of the desktop to move to.

bspc desktop -f $@
popup.sh -w 100 -m " Workspace ${@#?}"
