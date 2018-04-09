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
	exit 0;
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
}

setfanspeed() {
	if [ -z "$1" ]; then
		SPEED=0x"$QUIET"
	else
		SPEED=0x"$1"
	fi

	res=$(ipmitool raw 0x30 0x45 0x01 "$SPEED" )
}

usage() {
  echo -n "ipmi-fanspeed.sh [OPTION]...

Helper script for setting system fanspeeds on an IPMI controller.
Verified working on various recent Supermicro motherboards, eg X10SDV 

To run this you need to have read/write permissions on your IPMI device 
(normally /dev/ipmi0, but possibly something else). Usually this means
you need to run it as root

Note that this makes use of some IPMI RAW commands, so may or may not 
work on your platform. The profiles in particular may change, so feel free 
to edit them.

If your IPMI controller supports setting fan profiles via it's web interface, 
you can try setting a profile there and then running the IPMI raw command
used in the get function, which should give you the hex code for that mode.

 Options:
  -g, --get		Get current fan mode, and possibly PWM setings
  -f, --fullspeed	Set fan to fullspeed
  -h, --heavyio		Set fan to "Heavy IO" profile
  -q, --quiet		Set fan to "Quiet" profile
  -p, --pwm <%age>	Set PWM duty cycle to %age
      --help		Display usage text and ext

"
exit 0
}

TEMP=$(getopt -o hfqgp: --long heavyio,fullspeed,quiet,get,pwm:,help -n 'ipmi-fanspeed.sh' -- "$@")
eval set -- "$TEMP"

while true; do
    case "${1:-}" in
	--help) usage; shift ;;
        -h|--heavyio) setfanspeed $HEAVYIO ; shift ;; 
        -f|--fullspeed) setfanspeed $FULLSPEED ; shift ;;
        -q|--quiet) setfanspeed $QUIET ; shift ;;
        -g|--get) getfanspeed ; shift ;;
	-p|--pwm) setfanpwm $2 ; shift 2 ;;
        --) shift; break ;;
        *) usage; exit ;;
    esac
done

# always call getfanspeed
getfanspeed


