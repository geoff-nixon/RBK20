#!/bin/sh
MAC=`cat /tmp/MAC`;
TORVER=`cat /tmp/torlist.ver`
CIRCLE_ROOT=`cat /tmp/CIRCLE_ROOT`
rm -f /tmp/torlist.new.tgz
/usr/bin/curl --retry 1 -m 30 -s -o /tmp/torlist.new.tgz --cacert $CIRCLE_ROOT/scripts/Comodo-ca.bundle "https://download.meetcircle.co/dev/firmware/get_torlist.php?DEVID=$MAC&VER=$TORVER" || exit
if [ -s /tmp/torlist.new.tgz ]; then
	#sanity check tgz file size. size in kbytes
	gzsize=`du /tmp/torlist.new.tgz | cut -f 1`
	minsize=5
	if [ $gzsize -gt $minsize ]; then
		cd /tmp
		tar zxf /tmp/torlist.new.tgz
		if [ -s /tmp/torlist ]; then
			$CIRCLE_ROOT/ipsetload torlist /tmp/torlist
		fi
	fi
fi
rm -f /tmp/torlist.new.tgz
