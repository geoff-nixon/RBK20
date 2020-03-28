#!/bin/sh
MAC=`cat /tmp/MAC`;
VER=`cat /tmp/circleservers.ver`
CIRCLE_ROOT=`cat /tmp/CIRCLE_ROOT`
rm -f /tmp/circleservers.bin /tmp/circleserver.tgz
/usr/bin/curl -s --retry 1 -m 30 -o /tmp/circleservers.bin --cacert $CIRCLE_ROOT/scripts/Comodo-ca.bundle "https://download.meetcircle.co/dev/firmware/get_circleservers.php?DEVID=$MAC&VER=$VER" || exit
if [ -s /tmp/circleservers.bin ]; then
    /tmp/aescrypt -d -p a801e2f7bd4104073a296dc5c63857cf -o /tmp/circleservers.tgz /tmp/circleservers.bin || exit
    [ -s /tmp/circleservers.tgz ] || exit
    cd /tmp/
    tar zxf /tmp/circleservers.tgz
	if [ -s /tmp/circleservers ]; then
	    $CIRCLE_ROOT/ipsetload circleservers /tmp/circleservers
		cp -f /tmp/circleservers $CIRCLE_ROOT/scripts/circleservers.list
	fi
fi
rm -f /tmp/circleservers.bin /tmp/circleservers.tgz
