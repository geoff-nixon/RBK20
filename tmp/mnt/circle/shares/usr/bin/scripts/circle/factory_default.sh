sleep 2
CIRCLE_ROOT=`cat /tmp/CIRCLE_ROOT`
CIRCLE_BASE=`cat /tmp/CIRCLE_BASE`
echo "deleting configuration $CIRCLE_ROOT/configure.xml ..."
rm -f $CIRCLE_ROOT/configure.xm*
rm -rf $CIRCLE_ROOT/photos
rm -rf $CIRCLE_ROOT/category_data
rm -rf $CIRCLE_ROOT/notifications
rm -rf $CIRCLE_ROOT/tracking
rm -f $CIRCLE_ROOT/api_log.*
rm -f $CIRCLE_ROOT/passcod*
rm -f $CIRCLE_ROOT/app_list
# block SIGHUP	
killall circled
$CIRCLE_ROOT/stopcircle orbi &
handle_sig() {
	sig=$(($?))
	echo "sig = $sig"
	echo "cleaning up!!!"
	echo "deleting $CIRCLE_BASE..."
	rm -rf $CIRCLE_BASE
	rm -f dbmd5
	rm -f update_database.sh
	rm -f update_firmware.sh

	cd /tmp
	rm -f MAC
	rm -f ca.goclient.pem
	rm -f ca.rclient.pen
	rm -f circled.log
	rm -f circleservers
	rm -f circleservers.bin
	rm -f config.lock
	rm -f dhcp.log
	rm -f dhcp.log.lock
	rm -f dnscache.bin
	rm -rf enabled_notifications
	rm -f iplist
	rm -f last_device_update
	rm -f managed_devices.txt
	rm -f mmap_devices
	rm -f mmap_domains
	rm -f myap.txt
	rm -f myreboot
	rm -f notifications.lock
	rm -f platforms.bin
	rm -f torlist.new.tgz
	rm -f urls.tmp
	rm -f versions
	if grep -q RBR20 /module_name; then
		circled start -U ubi0 &
	elif grep -q NAND_FLASH /flash_type; then
		circled start -U ubi0 &
	else
		circled start -P mmcblk0p28 &
	fi
	sleep 2
	touch /tmp/circle_enabled.flag
	exit
}
# trap SIGHUP SIGINT SIGABRT　SIGQUIT SIGTERM
trap handle_sig 0 1 2 3 6 15

