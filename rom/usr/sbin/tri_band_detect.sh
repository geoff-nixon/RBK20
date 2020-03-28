#!/bin/sh

satellite_list="/tmp/hyt_result"
old_satellite_list="/tmp/old_hyt_result"
new_satellite_list="/tmp/new_hyt_result"
fifo_path="/tmp/wifi-listener.fifo"
support_file="/tmp/soapclient/support_feature_list/"
sync_flag_file="/tmp/soapclient/allconfig_result"
tri_band_cmd=2
wlan_updown_lockfile=/tmp/.wlan_updown_lockfile
wlan_updateconf_lockfile=/tmp/.wlan_updateconf_lockfile

# inform wifi-listener basic message and check file existence
inform_listener () {
    value=$1

    if [ "x$value" != "x" ]; then
        echo "[ TRI BAND ]$tri_band_cmd-$value update to $fifo_path" > /dev/console
        echo "$tri_band_cmd-$value" > $fifo_path
        if [ "`/bin/config get triband_mode`" != "$value" ]; then
            cnt="`/bin/config get triband_switch_count`"
            let switch_cnt=$cnt+1
            /bin/config set triband_mode=$value
            /bin/config set triband_switch_count="$switch_cnt"
            /bin/config commit
        fi
    fi
}

#base and satellite both support triband
check_wifi_system()
{
    triband_mode_cfg="`/bin/config get triband_mode`"
    awk -F [,] '{print $1 "=" $3}' $satellite_list | sort | sed 's/WLAN.*G/WLAN/g' | grep -v ETHER >  $new_satellite_list
    diff -i "$old_satellite_list" "$new_satellite_list"
    same="$?"
    if [ "$same" != "0" ] ; then
        check=0
        cp "$new_satellite_list" "$old_satellite_list"
        if check_satellite_list; then
            echo "join WLAN BH, updated dual band no wait" >/dev/console
            tri_band_enable=0
            inform_listener $tri_band_enable
        elif [ "$triband_mode_cfg" = "1" ]; then
            echo "In triband, updated triband no wait " >/dev/console
            tri_band_enable=1
            inform_listener $tri_band_enable
        else
            echo "In dual band, updated dual band to satellite " >/dev/console
            tri_band_enable=$triband_mode_cfg
            inform_listener $tri_band_enable
        fi
        return 0
    fi

    #check per MAC if support OrbiTribandSupport, and allconfig result
    all_support=1
    all_sync_done=1
    while read loop
        do
            #check mac
            mac=`echo $loop |awk -F [=] '{print $1}'`
            if [ "x$mac" = "x" ] ; then
                continue
            fi
            file=$support_file$mac
            if [ ! -f $file ]; then
                echo "$file allconfig not done !!!" >/dev/console
                all_sync_done=0
                continue
            fi
            support=`cat $file |grep "OrbiTribandSupport:" |awk -F ":" '{print $2}'`
            sync=`cat $sync_flag_file |grep "$mac 0" `
            if [ "x$support" = "x" ]; then
                all_support=0
                echo "satellite $mac not support triband function !!!" >/dev/console
            fi
            if [ "x$sync" = "x" ]; then
                all_sync_done=0
                echo "satellite $mac allconfig not done !!!" >/dev/console
            fi

        done < $new_satellite_list

    # satellite not support OrbiTribandSupport, always works on dual band
    if [ "$all_support" = "0" -a "$triband_mode_cfg" != "0" ]; then
        echo "satellite SOAP not support OrbiTribandSupport, change to dual band" >/dev/console
        tri_band_enable=0
        inform_listener $tri_band_enable
        check=0
        return 0
    fi

    if [ "$same" = "0" ] ; then
        check=$(($check + 1))
        # update tri_band_enable per 5min ~= t1
        if [ $check -ge 18 ]; then
            check=0
            # no satellites or no WLAN satellites, tri_band_enable=1
            if [ "$all_support" = "0" ] || check_satellite_list; then
                echo "WLAN BH or satellite not support OrbiTribandSupport, update to dual band!" >/dev/console
                tri_band_enable=0
                inform_listener $tri_band_enable
            elif [ "$triband_mode_cfg" = "1" ] ; then
                echo "Current is tri band!" >/dev/console
                tri_band_enable=1
                inform_listener $tri_band_enable
            elif [ "$all_sync_done" = "1" ] ; then
                #dual to triband, must all satellites allconifg sync done
                echo "all sync done, update to tri band!" >/dev/console
                tri_band_enable=1
                inform_listener $tri_band_enable
            else
                echo "All sync not done!" >/dev/console
                tri_band_enable=$triband_mode_cfg
                inform_listener $tri_band_enable
            fi
        fi
    fi
}

#Only base support triband
check_signal_router()
{
    awk -F [,] '{print $1 "=" $3}' $satellite_list | sort | sed 's/WLAN.*G/WLAN/g' >  $new_satellite_list
    diff -i "$old_satellite_list" "$new_satellite_list"
    same="$?"
    if [ "$same" != "0" ] ; then
        check=0
        cp "$new_satellite_list" "$old_satellite_list"
        if check_satellite_list; then
            tri_band_enable=0
            inform_listener $tri_band_enable
        fi
    else
        check=$(($check + 1))
        # update tri_band_enable per 5min ~= t1
        if [ $check -ge 18 ]; then
            check=0
            # no satellites satellites, tri_band_enable=1
            if check_satellite_list; then
                tri_band_enable=0
                inform_listener $tri_band_enable
            else
                tri_band_enable=1
                inform_listener $tri_band_enable
            fi
        fi
    fi
}

#
# Function to check whether there is any connected satellite, with "td s2" as
# failsafe for abnormal empty /tmp/hyt_result.
#
# Return value:
#     0: There is at least one connected satellite.
#     1: There is no connected satellite.
#
check_satellite_list()
{
    #
    # Whether number of DB entries in "td s2" of "hyt" is 0 or not.
    #
    # empty string: there is at least one DB entry.
    # non-empty string: there is no DB entry.
    #
    local no_DB_entry

    #
    # Both check_wifi_system() and check_signal_router() store the latest
    # /tmp/hyt_result as file $new_satellite_list, so let's just check file
    # $new_satellite_list.
    #
    if [ "$(cat "$new_satellite_list")" ]; then
        echo "[tri_band_detect] satellite is detected" >/dev/console
        return 0
    fi

    #
    # This failsafe code is adopted to check whether there is any connected
    # satellite in abnormal situation where there is connected satellite but
    # /tmp/hyt_result is empty.
    #
    no_DB_entry=$( (echo "td s2"; sleep 1) | hyt | grep '0 entries')
    if [ -z "$no_DB_entry" ]; then
        echo "[tri_band_detect] DB is NOT empty" >/dev/console
        return 0
    fi

    return 1
}


check=0
echo "" > $old_satellite_list
echo "" > $new_satellite_list
t1=300
t2=300

tri_band_enable=0
all_support=1
all_sync_done=1
#boot up first triband_mode is 0
/bin/config set triband_mode=0
/bin/config commit

while true; do
    # satellite_list update per 15s, sleep over 15s to make sure hyt_result updated.
    sleep 17

    if [ "x`/bin/config get dns_hijack`" != "x0" -o "x`/bin/config get triband_enable`" != "x1" ]; then
        #dnshijack or not support triband
        continue
    fi

    if [ ! -f "$satellite_list" -o ! -p "$fifo_path" ]; then
        #boot not done
        continue
    fi

    if [ -f $wlan_updateconf_lockfile -o -f $wlan_updown_lockfile ]; then
        #wlan restart not check tri_band_enable
        check=0
        continue
    fi

    if [ "x`/bin/config get dgc_func_base_have_tri_band`" = "x1" -a "x`/bin/config get dgc_func_sate_have_tri_band`" = "x1" ]; then
        check_wifi_system
    elif [ "x`/bin/config get dgc_func_base_have_tri_band`" = "x1" ] ; then
        check_signal_router
    else
        echo "dgc_func_base_have_tri_band not support." >/dev/console
    fi


done
