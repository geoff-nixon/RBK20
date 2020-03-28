#!/bin/sh

[ -z "$CIRCLE_ROOT" ] && { CIRCLE_ROOT=`cat /tmp/CIRCLE_ROOT`; [ -z "$CIRCLE_ROOT" ]; } && CIRCLE_ROOT=/mnt/shares/usr/bin/
[ -z "$CIRCLE_BASE" ] && { CIRCLE_BASE=`cat /tmp/CIRCLE_BASE`; [ -z "$CIRCLE_BASE" ]; } && CIRCLE_BASE=/mnt/shares/

DIR=$CIRCLE_ROOT
export PATH=$PATH:$DIR
export LD_LIBRARY_PATH=$DIR

#get IP address
iface="br0";

if [ -s /tmp/MAC ]; then 
	MAC=`cat /tmp/MAC`;
else
	MAC=`ifconfig br0 | awk '/HWaddr/{print $5;exit;}'`
	echo "$MAC" > $DIR/MAC;
	echo "$MAC" > /tmp/MAC;
fi

IP=`ifconfig $iface| awk '/inet addr:/{print substr($2,6);exit;}'`

my_loader_ver=`circled -v`;
my_firmware_ver=`cat $CIRCLE_BASE/VERSION`;
my_database_ver=`cat $CIRCLE_BASE/DATABASE_VERSION`;
my_platforms_ver=`cat $CIRCLE_ROOT/platforms.ver`;

if [ -e /tmp/circle_running.flag ]; then
	active="1"
	$CIRCLE_ROOT/sget -T 10 -q -O /tmp/versions "https://download.meetcircle.co/dev/firmware/netgear/check_version.php?DEVID=$MAC&LVER=$my_loader_ver&FVER=$my_firmware_ver&DBVER=$my_database_ver&PVER=$my_platforms_ver&ACTIVE=$active&IP=$IP"
	rm -f /tmp/versions
fi
