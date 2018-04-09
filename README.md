ipmi-fanspeed.sh

To run this you need to have read/write permissions on your IPMI device 
(normally /dev/ipmi0, but possibly something else). Usually this means
you need to run it as root

Note that this makes use of some IPMI RAW commands, so may or may not 
work on your platform. The profiles in particular may change, so feel free 
to edit them.

If your IPMI controller supports setting fan profiles via it's web interface, 
you can try setting a profile there and then running the IPMI raw command
used in the get function, which should give you the hex code for that mode.


https://forums.servethehome.com/index.php?resources/supermicro-x9-x10-x11-fan-speed-control.20/ is a fantastic looking resource that covers off a lot of the underlying information. 

This script is missing some bits from the above link - it's only setting for one zone when you do PWM, for example

