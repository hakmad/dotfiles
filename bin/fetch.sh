#!/bin/bash

# Script for getting system information. Output from this script is designed
# to be human readable (similar to fetch, hence the name),

# Clear the screen.
clear

# Set colours for information labels.
C="\033[1;30m" # grey
NC="\033[0m" # reset

# Source /etc/os-release, has some useful information.
. /etc/os-release

# Get CPU information.
CPU=$(lscpu | sed -nr '/Model name/ s/  / /g; s/.*:\s*(.*) @ .*/\1/p')

# Get RAM information.
USED_RAM=$(free -h --si | awk '/Mem/ {print $3}')
TOTAL_RAM=$(free -h --si | awk '/Mem/ {print $2}')

# Get disk information.
ROOT_DISK=$(lsblk -l | grep "/" | grep -v "/boot" | cut -d " " -f 1)
USED_DISK=$(df -h | grep $ROOT_DISK | awk '{print $3}')
TOTAL_DISK=$(df -h | grep $ROOT_DISK | awk '{print $2}')

# Get battery information.
BATTERY_STATUS=$(acpi --battery | cut -d "," -f 1 | cut -d " " -f 3)
BATTERY_REMAINING=$(acpi --battery | cut -d " " -f 5)

# Get number of packages.
PACKAGES=$(pacman -Q | wc -l)

# Output information.
echo -e "$C \b$USER$NC@$C \b$HOSTNAME$NC\n"
echo -e "$C \bOS:$NC $NAME"
echo -e "$C \bCPU:$NC $CPU"
echo -e "$C \bRAM:$NC $USED_RAM / $TOTAL_RAM"
echo -e "$C \bDisk:$NC $USED_DISK / $TOTAL_DISK"
echo -e "$C \bBattery:$NC $BATTERY_REMAINING ($BATTERY_STATUS)"
echo -e "$C \bPackages:$NC $PACKAGES"

# A little colour fun. :D
printf "\n"

for i in {0..7}; do
        printf "\033[48;5;${i}m  \033[0m"
done

printf "\n"

for i in {8..16}; do
        printf "\033[48;5;${i}m  \033[0m"
done

printf "\n"

# Exit.
exit 0
