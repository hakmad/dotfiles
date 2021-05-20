#!/bin/bash

# Script for notifying me of system information. Uses popup.sh to create
# desktop popups.

# Remove temporary files for storing information.
rm /tmp/network

# Get battery information.
battery() {
	BATTERY_PERC=$(get-battery.sh --percentage)
	BATTERY_STATUS=$(get-battery.sh --status)

	# If the battery is full...
	if [[ $(echo $BATTERY_PERC | sed "s/%//g") == 100 ]] && \
		[[ $BATTERY_STATUS == "Full" ]]; then
		popup.sh -w 200 -d 3 -m " Unplug laptop - Battery full" &
	# If battery percentage is greater than 90%...
	elif [[ $(echo $BATTERY_PERC | sed "s/%//g") -ge 90 ]] && \
		[[ $BATTERY_STATUS == "Charging" ]]; then
		popup.sh -w 210 -d 3 \
			-m " Unplug laptop - Battery at $BATTERY_PERC" &
	elif [[ $(echo $BATTERY_PERC | sed "s/%//g") -lt 10 ]] && \
		[[ $BATTERY_STATUS == "Discharging" ]]; then
		popup.sh -w 210 -d 3 \
			-m " Plug in laptop - Battery at $BATTERY_PERC" &
	fi
}

# Get network information.
network() {
	CURRENT_NETWORK=$(iwgetid -r)
	PREVIOUS_NETWORK=$(cat /tmp/network)
	
	# If network has changed...
	if [[ "$CURRENT_NETWORK" != "$PREVIOUS_NETWORK" ]]; then
		# Create popup with output of get-network.sh.
		popup.sh -w 240 -d 3 -m " $(get-network.sh)" &
		
		# Overwrite /tmp/network.
		echo $CURRENT_NETWORK > /tmp/network
	fi
}

# Run functions forever.
while true; do
	battery
	network
	sleep 1
done

# Exit.
exit 0
