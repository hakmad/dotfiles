#!/bin/bash

# Script for outputting network information.
# 
# The usage of this script is as follows:
# 	network.sh

NETWORK=$(iwgetid -r)

if [[ -z $NETWORK ]]; then
	echo "Not connected to a network"
else
	echo "Connected to $NETWORK"
fi
