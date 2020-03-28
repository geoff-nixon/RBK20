wlan_updown_lockfile=/tmp/.wlan_updown_lockfile
wlan_updateconf_lockfile=/tmp/.wlan_updateconf_lockfile


hyfi_network_sync() {
        lock -w /var/run/hyfi_network.lock
}

hyfi_network_restart() {
	trap __hyfi_trap_cb INT ABRT QUIT ALRM

	lock /var/run/hyfi_network.lock
	hyfi_echo "hyfi network" "process $0 ($$) requested network restart"
	/etc/init.d/network restart

	local radios=`uci show wireless | grep ".disabled=" | grep -v "@" | wc -l`
	local vaps=`uci show wireless | grep "].disabled=0" | wc -l`
	if [ $vaps -gt $radios ]; then
		# Workaround for Wi-Fi, needs a clean environment
		[ ! -f /sbin/wlan ] && {
			env -i /sbin/wifi
		}
	fi

	lock -u /var/run/hyfi_network.lock
	[ -f /sbin/wlan ] && {

		local triband_enable=`/bin/config get triband_enable`
		if [ "$triband_enable" = "1" ]; then
			/sbin/wlan updateconf
			/sbin/wlan down
			/sbin/wlan up
		else
			for i in $(cat /tmp/wifi_topology);
				do  mode=`echo  "$i" | awk -F ':' '{print $1}'` ;
					if [ "$mode" = "NORMAL" ]; then
					radio=`echo  "$i" | awk -F ':' '{print $3}'`
					/sbin/wlan down $radio
				fi
				done
			/sbin/wlan up
		fi

	}

	trap - INT ABRT QUIT ALRM
}

hyfi_network_update_dni_wifi(){
    local checking="TRUE" 
    while [ "${checking}" = "TRUE" ];
    do
        if [ -f $wlan_updateconf_lockfile -o -f $wlan_updown_lockfile ]; then
            echo "[WSPLCD]: Waiting gathering lock for update wireless config" > /dev/console
            sleep 5
        else
            checking="FALSE"
        fi
    done

    echo wsplcd > $wlan_updateconf_lockfile
    echo "[WSPLCD] Start update config to datalib" > /dev/console

    /sbin/uci2dnicfg.sh wsplcd

    rm $wlan_updateconf_lockfile
    wlan retrycheck
}
