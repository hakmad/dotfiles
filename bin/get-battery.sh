#!/bin/bash

# Script for outputting battery information.
# 
# The usage of this script is as follows:
# 	get-battery.sh -a, --all	Get all information.
# 	get-battery.sh -p, --percentage	Get battery percentage.
# 	get-battery.sh -t, --time	Get time remaining.
# 	get-battery.sh -s, --status	Get status infomation.
# 	get-battery.sh -h, --help	Show this help.

# Get percentage.
return_percentage() {
	PERCENTAGE=$(acpi | cut -d " " -f 4 | tr -d ",")
	echo $PERCENTAGE
}

# Get time.
return_time() {
	TIME=$(acpi | cut -d "," -f 3)
	echo $TIME
}

# Get status.
return_status() {
	STATUS=$(acpi | cut -d " " -f 3 | tr -d ",")
	echo $STATUS
}

# Output percentage.
output_percentage() {
	echo $(return_percentage)
}

# Output time.
output_time() {
	echo "$(return_time)"
}

# Output status.
output_status() {
	echo $(return_status)
}

# Output everything.
output_all() {
	echo "$(return_status), $(return_time) ($(return_percentage))"
}

# Show help.
show_help() {
	head ~/.bin/get-battery.sh -n 10 | tail -n 8 | sed 's/# //g'
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
		-t | --time)
			output_time
			exit
			;;
		-s | --status)
			output_status
			exit
			;;
		-h | --help)
			show_help
			exit
			;;
		*)
			exit 1
			;;
	esac
done
