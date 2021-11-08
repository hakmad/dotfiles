#!/bin/bash

# Script for notifying user of events.

rm /tmp/network

# Get battery information and create popups.
battery() {
	PERCENTAGE=$(get-battery.sh --percentage)
	PERCENTAGE_NUM=$(echo $PERCENTAGE | sed "s/%//g")
	STATUS=$(get-battery.sh --status)

	if [[ $PERCENTAGE_NUM == 100 ]] && [[ $STATUS == "Full" ]]; then
		popup.sh -w 200 -d 3 -m " Unplug laptop - Battery full" &
	elif [[ $PERCENTAGE_NUM -ge 90 ]] && [[ $STATUS == "Charging" ]]; then
		popup.sh -w 200 -d 3 \
			-m " Unplug laptop - Battery at $PERCENTAGE" &
	elif [[ $PERCENTAGE_NUM -lt 10 ]] && \
		[[ $STATUS == "Discharging" ]]; then
		popup.sh -w 200 -d 3 \
			-m " Plug in laptop - Battery at $PERCENTAGE" &
	fi
}

# Get network information and create popups.
network() {
	CURRENT=$(iwgetid -r)
	PREVIOUS=$(cat /tmp/network)

	if [[ $CURRENT != $PREVIOUS ]]; then
		popup.sh -w 250 -d 3 -m " $(get-network.sh)" &

		echo $CURRENT > /tmp/network
	fi
}

# Until killed or otherwise...
while true; do
	battery
	network
	sleep 1
done
