#!/bin/bash

# Script for showing system information.

# Clear the screen.
clear

# Colours.
C="\033[1;37m"
NC="\033[0m"

# Get information.
source /etc/os-release

CPU=$(lscpu | sed -nr "/Model name/ s/.*:\s*(.*) @ .*/\1/p")

USED_RAM=$(free -h --si | awk '/Mem/ {print $3}')
TOTAL_RAM=$(free -h --si | awk '/Mem/ {print $2}')

ROOT_DISK=$(lsblk -l | grep "/" | grep -v "/boot" | cut -d " " -f 1)
USED_DISK=$(df -h | grep $ROOT_DISK | awk '{print $3}')
TOTAL_DISK=$(df -h | grep $ROOT_DISK | awk '{print $2}')

BATTERY_STATUS=$(acpi --battery | cut -d "," -f 1 | cut -d " " -f 3)
BATTERY_REMAINING=$(acpi --battery | cut -d " " -f 5)

# Show information.
echo -e "$C \b$USER$NC@$C \b$HOSTNAME$NC\n"
echo -e "$C \bOS:$NC $NAME"
echo -e "$C \bCPU:$NC $CPU"
echo -e "$C \bRAM:$NC $USED_RAM / $TOTAL_RAM"
echo -e "$C \bDisk:$NC $USED_DISK / $TOTAL_DISK"
echo -e "$C \bBattery:$NC $BATTERY_REMAINING ($BATTERY_STATUS)"
