#!/bin/bash

# Script for moving a node to a workspace.

# Move node to given workspace.
bspc node -d "$@"

# Create popup displaying where the node has been moved to.
popup.sh -w 150 -m " Moved to workspace ${@#?}"
