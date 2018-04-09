#!/bin/bash

# Copyright (c) 2018 Daniel Lawson 

set -euo pipefail

HEAVYIO=04
FULLSPEED=01
QUIET=00

getfanpwm() {
	PWM=$( ipmitool raw 0x30 0x70 0x66 0x00 | tr -d ' ')
	PERCENT=$(printf "%0d" 0x$PWM)
	echo "Fan set to ${PERCENT}% duty cycle"
}

getfanspeed() {
	SPEED=$(ipmitool raw 0x30 0x45 0x00 )
	if [ "$SPEED" -eq "$HEAVYIO" ]; then 
		echo "Fan set to Heavy IO";
	elif [ "$SPEED" -eq "$FULLSPEED" ]; then
		echo "Fan set to Full Speed";
		getfanpwm
	elif [ "$SPEED" -eq "$QUIET" ]; then
		echo "Fan set to Quiet";
	else 
		echo "Unknown response code \"$SPEED\" ";
	fi
}

setfanpwm() {
	if [ -z "$1" ]; then
		PWM=0x64
	else
		PWM=$(printf "0x%0x" $1)
	fi


	res=$(ipmitool raw 0x30 0x45 0x01 0x"$FULLSPEED" )
	sleep 1
	res=$(ipmitool raw 0x30 0x70 0x66 0x01 0x00 "$PWM" )
	sleep 1
	getfanspeed
}

setfanspeed() {
	if [ -z "$1" ]; then
		SPEED=0x"$QUIET"
	else
		SPEED=0x"$1"
	fi

	res=$(ipmitool raw 0x30 0x45 0x01 "$SPEED" )
	getfanspeed
}

TEMP=$(getopt -o hfqgp: --long heavyio,fullspeed,quiet,get,pwm: -n 'fanspeed.sh' -- "$@")
eval set -- "$TEMP"

while true; do
    case "$1" in
        -h|--heavyio) setfanspeed $HEAVYIO ; shift ;; 
        -f|--fullspeed) setfanspeed $FULLSPEED ; shift ;;
        -q|--quiet) setfanspeed $QUIET ; shift ;;
        -g|--get) getfanspeed ; shift ;;
	-p|--pwm) setfanpwm $2 ; shift 2 ;;
        --) shift; break ;;
        *) echo "Internal error!" ; exit 1;;
    esac
done




