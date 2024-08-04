#!/bin/bash

# Script for notifying user of events.

rm /tmp/network

# Get battery information and create popups.
battery() {
	PERCENTAGE=$(battery.sh percentage | sed "s/\%//")
	STATUS=$(battery.sh status)

	# Create popups.
	if [[ ! -f /tmp/popups/notif_battery ]]; then
		if [[ $PERCENTAGE -ge 95 ]] && [[ $STATUS == "Charging" ]]; then
			popup.sh -d infinity -m "Unplug laptop - Battery high" -y 50 -p "notif_battery" &
		elif [[ $PERCENTAGE -lt 10 ]] && [[ $STATUS == "Discharging" ]]; then
			popup.sh -d infinity -m "Plug in laptop - Battery low" -y 50 -p "notif_battery" &
		fi
	fi

	# Kill popups.
	if [[ -f /tmp/popups/notif_battery ]]; then
		if { [[ $PERCENTAGE -lt 90 ]] && [[ $STATUS == "Charging" ]] } || \
		{ [[ $PERCENTAGE -ge 10 ]] && [[ $STATUS == "Discharging" ]] }; then
			kill -9 $(< /tmp/popups/notif_battery)
			rm /tmp/popups/notif_battery
		fi
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
