#!/bin/bash

# Script for getting a password from a KeePassXC database.

# Stop the script if there are errors.
set -e

# Location for passwords DB and keyfile.
DB="$HOME/.passwords/passwords.kdbx"
KEYFILE="$HOME/.secrets/keyfile.key"

# Get password from user.
PASSWORD=$(echo " " | menu.sh -l 0 -mask -p "Password:")

# List choices from passwords DB and copy selected choice to clipboard.
CHOICES=$(printf "%s\n\r" "$PASSWORD" | keepassxc-cli ls "$DB" -q -k $KEYFILE)
CHOICE=$(printf "%s" "$CHOICES" | menu.sh -p "Choice:")

# List attributes.
ATTRIBUTES="Password\nUsername"
ATTRIBUTE=$(echo -e $ATTRIBUTES | menu.sh -p "Attribute:")

# Get password from DB and copy to clipboard.
printf "%s\n\r" "$PASSWORD" | keepassxc-cli clip -q "$DB" "$CHOICE" -a "$ATTRIBUTE" -k $KEYFILE
popup.sh -m "Password cleared from clipboard" -d 3
