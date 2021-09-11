#!/bin/bash

NETWORK=$(iwgetid -r)

if [[ -z $NETWORK ]]; then
	echo "Not connected to a network"
else
	echo "Connected to $NETWORK"
fi
