#!/bin/bash

# Script to output the current network in a user-friendly manner.

NETWORK=$(iwgetid -r)

if [[ $NETWORK == "" ]]; then
	OUTPUT="Not connected to a network"
else
	OUTPUT="Connected to $NETWORK"
fi

echo $OUTPUT
