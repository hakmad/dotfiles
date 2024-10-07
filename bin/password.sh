#!/bin/bash

# Script for getting a password from a KeePassXC database.

# Stop the script if there are errors.
set -e

# Location for passwords DB.
DB="$HOME/.passwords/passwords.kdbx"

# Get password from user.
PASSWORD=$(echo " " | menu.sh -l 0 -mask -p "Password:")

# List choices from passwords DB and copy selected choice to clipboard.
CHOICES=$(printf "%s\n\r" "$PASSWORD" | keepassxc-cli ls "$DB" -q)
CHOICE=$(printf "%s" "$CHOICES" | menu.sh)

# Get password from DB and copy to clipboard.
printf "%s\n\r" "$PASSWORD" | keepassxc-cli clip -q "$DB" "$CHOICE"
popup.sh -m "Password cleared from clipboard" -d 3
