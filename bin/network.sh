#!/bin/bash

# Script for outputting network information.
# 
# The usage of this script is as follows:
# 	network.sh

NETWORK=$(iwgetid -r)

if [[ -z $NETWORK ]]; then
	echo "None"
else
	echo "$NETWORK"
fi
