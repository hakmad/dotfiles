#!/bin/bash

# Script for getting a password from a KeePassXC database.

# Stop the script if there are errors.
set -e

# Location for passwords DB.
DB=~/share/passwords.kdbx

# Get password from user.
PASSWORD=$(echo " " | menu.sh -mask -p "Password:")

# List choices from passwords DB and copy selected choice to clipboard.
CHOICES=$(printf $PASSWORD"\n\r" | keepassxc-cli ls $DB -q)
CHOICE=$(printf "$CHOICES" | menu.sh)

# Get password from DB and copy to clipboard.
popup.sh -m "Copying password for $CHOICE" -d 3
printf $PASSWORD"\n\r" | keepassxc-cli clip -q $DB "$CHOICE"
popup.sh -m "Password cleared from clipboard" -d 3
