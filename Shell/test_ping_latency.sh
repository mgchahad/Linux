#!/bin/bash
### SCRIPT FOR TEST PING LATENCY
### CREATED BY CHAHAD - VERSION 2.1 - 11/05/2019

### VARIABLES ###
FILE_RESULT=/tmp/ping_time
FILE_AVERAGE=/tmp/average

### FUNCTIONS ###
### SPINNER ###
spinner () {
	PID=$!
	i=1
	delay=0.5
	sp="-=_="
	echo -n ' '
	while [ -d /proc/$PID ]; do
        	temp=${sp#?}
        	printf " [%c] " "$sp"
        	sp=$temp${sp%"$temp"}
        	sleep $delay
        	printf "\b\b\b\b\b${sp:i++%${#sp}:0}"
	done
	printf "\b\b\b\b\b\b"
}

### RUNNING PING FUNCTION ###
run_ping () {
	ping -c 10 "$IP_DST" | awk '{print $7}' | grep -vE '(data|packet)' | sed "s/time=//g" > "$FILE_RESULT"
}

### CALCULATOR FUNCTION ###
average_ping () {
	AVERAGE=$(awk '{s+=$1 / 10} END {printf "%.0f", s}' "$FILE_RESULT")
	echo AVERAGE="$AVERAGE"ms
	echo Destination: "$IP_DST" Average: "$AVERAGE" ms >> "$FILE_AVERAGE"
}


### CHECK PING FUNCTION ###
check_ping () {
	if [ "$AVERAGE" -le 200 ]; then
	echo -e "\nTEST PING OK\n"
	echo "Last Results"
	tail "$FILE_AVERAGE"
	exit 0
else 
	echo -e "\nCRITICAL - LINK WITH POSSIBLE DELAY\n"
	echo "Last Results"
	tail "$FILE_AVERAGE"
	exit 1
fi
}

### RUNNING ###
# SET ADDRESS
echo -e "\nPlease, set the IP address or domain name:\n"
read IP_DST

echo -e "\nPlease wait a while...\n"

# COLLECTING PING TIME DELAY
run_ping &
spinner

# CALCULATING
average_ping

# CHECKING PING
check_ping

