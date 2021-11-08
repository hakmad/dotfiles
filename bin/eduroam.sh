#!/bin/bash

# Script for setting up and connecting to eduroam.

# Basic variables.
NETWORK="eduroam"
CERT_FILE=~/.local/share/certs/eduroam.pem
INTERFACE=$(nmcli device status | grep wifi | grep -v p2p | \
	awk '{ print $1 }')

echo "Using $INTERFACE as interface..."

echo "Attempting to delete old configurations..."
nmcli connection delete eduroam

# Ask for username.
read -p "Enter username: " USERNAME

echo "Adding $NETWORK to NetworkManager..."
nmcli connection add \
	type wifi \
	con-name $NETWORK \
	ifname $INTERFACE \
	ssid $NETWORK -- \
	wifi-sec.key-mgmt wpa-eap \
	802-1x.eap peap \
	802-1x.phase2-auth mschapv2 \
	802-1x.identity $USERNAME \
	802-1x.ca-cert $CERT_FILE

echo "Connecting to $NETWORK..."
nmcli connection up "eduroam" --ask
