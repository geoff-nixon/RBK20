#!/bin/sh
if [ $# != 1 ] ; then
	echo "create_debug_file.sh <root_dir>"
	exit 1
fi

mkdir -p $1/debug
rm -f $1/debug.tgz

#Add tmp files
mkdir -p $1/debug/tmp
cp -f /tmp/MAC /tmp/TZ /tmp/locale $1/debug/tmp/
cp -f /tmp/battery_percent /tmp/blueled /tmp/current_channel /tmp/eth_connected /tmp/flag_* $1/debug/tmp/
cp -f /tmp/dhcp.log /tmp/mdns.log /tmp/iplist /tmp/ip6list.txt /tmp/ip6-router.txt /tmp/managed_devices.txt $1/debug/tmp/
cp -f /tmp/versions /tmp/circleservers.ver /tmp/torlist.ver $1/debug/tmp/

#Add files from main Circle dir
cp -f $1/configure.xml $1/platforms.ver $1/passcode $1/max_api $1/debug/
cp -f $1/app_list $1/extenders.txt $1/go_devices $1/mycircle_devices $1/debug/

#remove wifi key in configure.xml
value="********"
sed -i "s|\(<key>\)[^<>]*\(</key>\)|\1${value}\2|" $1/debug/configure.xml
token="************-****************-********.******"
cat $1/debug/app_list | awk -v var="$token" '$3=var' > $1/debug/app_list.tmp
mv $1/debug/app_list.tmp $1/debug/app_list

#Add command output files
mkdir -p $1/debug/out
ifconfig > $1/debug/out/ifconfig.out
uptime > $1/debug/out/uptime.out
date > $1/debug/out/date.out

tar -C $1 -czf $1/debug.tgz debug

if [ ! -s $1/debug.tgz ] ; then
	echo "failed to create debug file"
	exit 1
fi

#aescrypt -e -p $2 -o $1 /mnt/shares/usr/bin/debug.tgz
#rm -f /mnt/shares/usr/bin/debug.tgz

#if [ ! -s $1 ] ; then
#	echo "failed to encrypt debug file"
#	exit 1
#fi

exit 0
