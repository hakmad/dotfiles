#!/bin/bash

# Script to output the current battery information in a user-friendly manner.
#
# The usage of this script is as follows:
# 	get-battery.sh -a, --all		Output all battery
# 						information.
# 	get-battery.sh -p, --percentage		Output current battery
# 						percentage.
# 	get-battery.sh -t, --time		Output current battery
# 						time remaining.
# 	get-battery.sh -s, --status		Output current battery
#						status.

output_all() {
	STATUS=$(acpi | cut -d " " -f 3 | sed "s/,//g")
	PERCENTAGE=$(acpi | cut -d " " -f 4 | sed "s/,//g")
	TIME=$(acpi | cut -d "," -f 3)

	OUTPUT="$STATUS, $TIME ($PERCENTAGE)"
	echo $OUTPUT
}

output_percentage() {
	PERCENTAGE=$(acpi | cut -d " " -f 4 | sed "s/,//g")

	OUTPUT="$PERCENTAGE"
	echo $OUTPUT
}

output_status() {
	STATUS=$(acpi | cut -d " " -f 3 | sed "s/,//g")
	
	OUTPUT="$STATUS"
	echo $OUTPUT
}

output_time() {
	TIME=$(acpi | cut -d "," -f 3)

	OUTPUT="$TIME"
	echo $OUTPUT
}

# Get command line arguments.
while [[ $1 != "" ]]; do
	case $1 in
		-a | --all)
			output_all
			exit
			;;
		-p | --percentage)
			output_percentage
			exit
			;;
		-s | --status)
			output_status
			exit
			;;
		-t | --time)
			output_time
			exit
			;;
		*)
			exit 1
			;;
	esac
done
