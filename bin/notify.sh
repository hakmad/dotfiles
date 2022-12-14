#!/bin/bash

# Script for notifying user of events.

rm /tmp/network

# Get battery information and create popups.
battery() {
	PERCENTAGE=$(battery.sh percentage | sed "s/\%//")
	STATUS=$(battery.sh status)

	if [[ $PERCENTAGE == 100 ]] && [[ $STATUS == "Full" ]]; then
		popup.sh -d 5 -m "Unplug laptop - Battery full" -y 50 &
	elif [[ $PERCENTAGE -ge 98 ]] && [[ $STATUS == "Charging" ]]; then
		popup.sh -d 5 -m "Unplug laptop - Battery high" -y 50 &
	elif [[ $PERCENTAGE -lt 10 ]] && [[ $STATUS == "Discharging" ]]; then
		popup.sh -d 5 -m "Plug in laptop - Battery low" -y 50 &
	fi
}

# Get network information and create popups.
network() {
	CURRENT=$(network.sh)
	PREVIOUS=$(cat /tmp/network)

	if [[ "$CURRENT" != "$PREVIOUS" ]]; then
		popup.sh -d 3 -m "Network: $CURRENT" -y 50 &

		echo "$CURRENT" > /tmp/network
	fi
}

# Until killed or otherwise...
while true; do
	battery
	network
	sleep 5
done
