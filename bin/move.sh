#!/bin/bash

bspc node -d "$@"
popup.sh -w 150 -m " Moved to workspace ${@#?}"
