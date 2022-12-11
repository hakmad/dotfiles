#!/bin/bash

# Script for outputting battery information.
# 
# The usage of this script is as follows:
# 	battery.sh percentage		Get battery percentage.
# 	battery.sh time			Get time remaining.
# 	battery.sh status		Get status infomation.
# 	battery.sh help			Show this help.

# If no argument supplied, exit.
if [[ -z $1 ]]; then
	echo "Invalid arguments supplied! Exiting."
	exit 1
fi

# Check arguments and output information.
case $1 in
	percentage)
		echo $(acpi | grep "Battery 0" | cut -d " " -f 4 | tr -d ",")
		exit
		;;
	time)
		echo $(acpi | grep "Battery 0" | cut -d " " -f 5 | tr -d ",")
		exit
		;;
	status)
		echo $(acpi | grep "Battery 0" | cut -d " " -f 3 | tr -d ",")
		exit
		;;
	help)
		head ${HOME}/.bin/battery.sh -n 9 | tail -n 7 | sed "s/# //g"
		exit
		;;
	*)
		echo "Invalid arguments supplied! Exiting."
		exit
		;;
esac
