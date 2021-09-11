#!/bin/bash

return_percentage() {
	PERCENTAGE=$(acpi | cut -d " " -f 4 | tr -d ",")
	echo $PERCENTAGE
}

return_time() {
	TIME=$(acpi | cut -d "," -f 3)
	echo $TIME
}

return_status() {
	STATUS=$(acpi | cut -d " " -f 3 | tr -d ",")
	echo $STATUS
}

output_percentage() {
	echo $(return_percentage)
}

output_time() {
	echo "$(return_time)"
}

output_status() {
	echo $(return_status)
}

output_all() {
	echo "$(return_status), $(return_time) ($(return_percentage))"
}

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
		*)
			exit 1
			;;
	esac
done
