#!/bin/bash

# Script for outputting battery information.
# 
# The usage of this script is as follows:
# 	get-battery.sh percentage	Get battery percentage.
# 	get-battery.sh time		Get time remaining.
# 	get-battery.sh status		Get status infomation.
# 	get-battery.sh help		Show this help.

# If no argument supplied, exit.
if [[ -z $1 ]]; then
	echo "Invalid arguments supplied! Exiting."
	exit 1
fi

# Check arguments and output information.
case $1 in
	percentage)
		echo $(acpi | cut -d " " -f 4 | tr -d ",")
		exit
		;;
	time)
		echo $(acpi | cut -d " " -f 5 | tr -d ",")
		exit
		;;
	status)
		echo $(acpi | cut -d " " -f 3 | tr -d ",")
		exit
		;;
	help)
		head ${HOME}/.bin/battery.sh -n 9 | tail -n 7 | sed 's/# //g'
		exit
		;;
	*)
		echo "Invalid arguments supplied! Exiting."
		exit
		;;
esac
