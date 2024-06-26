#!/bin/bash

# Script for showing system information.

# Clear the screen.
clear

# Colours.
C="\033[1m"
NC="\033[0m"

# Get information.
source /etc/os-release

CPU=$(lscpu | sed -nr "/Model name/ s/.*:\s*(.*) @ .*/\1/p")

USED_RAM=$(free -h --si | awk '/Mem/ {print $3}')
TOTAL_RAM=$(free -h --si | awk '/Mem/ {print $2}')

ROOT_DISK=$(lsblk -l | grep "/$" | cut -d " " -f 1)
USED_DISK=$(df -h | grep $ROOT_DISK | awk '{print $3}')
TOTAL_DISK=$(df -h | grep $ROOT_DISK | awk '{print $2}')

BATTERY_INFO="$(battery.sh status) - $(battery.sh time) remaining ($(battery.sh percentage))"

UPTIME="$(uptime -p | sed "s/up //") (since $(uptime -s))"

# Show information.
echo -e "$C \b$USER$NC@$C \b$HOSTNAME$NC\n"
echo -e "$C \bOS:$NC $NAME"
echo -e "$C \bCPU:$NC $CPU"
echo -e "$C \bRAM:$NC $USED_RAM / $TOTAL_RAM"
echo -e "$C \bDisk:$NC $USED_DISK / $TOTAL_DISK"
echo -e "$C \bUptime:$NC $UPTIME"
echo -e "$C \bBattery:$NC $BATTERY_INFO"

# Show colour stuff. :D
printf "\n"

for i in {0..8}; do
	printf "\033[0;4"$i"m   \033[0m"
done

printf "\n"

for i in {0..8}; do
	printf "\033[0;4"$i"m   \033[0m"
done

printf "\n"
