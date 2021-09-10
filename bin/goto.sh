#!/bin/bash

bspc desktop -f $@
popup.sh -w 100 -m " Workspace ${@#?}"
