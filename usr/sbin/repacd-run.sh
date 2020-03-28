#!/bin/sh
# Copyright (c) 2015-2016 Qualcomm Atheros, Inc.
#
# All Rights Reserved.
# Qualcomm Atheros Confidential and Proprietary.

REPACD_DEBUG_OUTOUT=1

. /lib/functions/repacd-gwmon.sh
. /lib/functions/repacd-wifimon.sh
. /lib/functions/repacd-ethmon.sh
. /lib/functions/repacd-lp.sh
. /lib/functions/repacd-netdet.sh
. /lib/functions/repacd-led.sh

GWMON_DEBUG_OUTOUT=$REPACD_DEBUG_OUTOUT

local cur_role managed_network
local link_check_delay
local daisy_chain
local restart_wifi=0
local lock_key_2G=0
local lock_key_5G=0
local associate_state=0
local bh_5g_iface=`/bin/config get wl5g_BACKHAUL_STA`
local bh_24g_iface=`/bin/config get wl2g_BACKHAUL_STA`

__repacd_info() {
    local stderr=''
    if [ "$REPACD_DEBUG_OUTOUT" -gt 0 ]; then
        stderr='-s'
    fi

    logger $stderr -t repacd -p user.info "$1"
}

__repacd_restart() {
    local __mode="$1"
    __repacd_info "repacd: restart in $__mode mode"

    /etc/init.d/repacd restart_in_${__mode}_mode
    exit 0
}

__repacd_update_mode() {
    local new_mode=$1
    if [ "$new_mode" -eq $GWMON_MODE_CAP ]; then
		echo "1" >/tmp/link_status_eth
		echo "0" >/tmp/link_status
		echo "0" >/tmp/link_status_5g
        __repacd_info "Restarting in CAP mode"
		[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! Restarting in CAP mode ....." > /dev/console
		__repacd_restart 'cap'
    elif [ "$new_mode" -eq $GWMON_MODE_NON_CAP ]; then
		echo "0" >/tmp/link_status_eth
        __repacd_info "Restarting in NonCAP mode"
		[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! Restarting in NonCAP mode ....." > /dev/console
        __repacd_restart 'noncap'
    fi
}

__run_iface_is_assoc(){
    local sta_iface=$1

    if [ -n $sta_iface ]; then 
        local assoc_str=$(iwconfig $sta_iface)
	
        if $(echo "$assoc_str" | grep 'Access Point: ' | grep -v 'Not-Associated' > /dev/null); then
            return 0
        else
            return 1
        fi
    else
             # An unknown STA interface is considered not associated.
            return 1
    fi
}

__repacd_check_associated(){
    local sta_iface_24g=$1
    local sta_iface_5g=$2
    
    if __run_iface_is_assoc $sta_iface_24g  &&
       __run_iface_is_assoc $sta_iface_5g ; then
         associate_state=1
         # echo "== All backhaul connected" > /dev/console

    elif !(__run_iface_is_assoc $sta_iface_24g) &&
         (__run_iface_is_assoc $sta_iface_5g); then
         associate_state=2
         # echo "== Only 5g backhaul connected"  > /dev/console

    elif (__run_iface_is_assoc $sta_iface_24g) &&
         !(__run_iface_is_assoc $sta_iface_5g); then
         associate_state=3
         # echo "== Only 2.4g backhaul connected"  > /dev/console

    elif !(__run_iface_is_assoc $sta_iface_24g) &&
         !(__run_iface_is_assoc $sta_iface_5g); then
         associate_state=0
         # echo "== All backhaul disconnected"  > /dev/console
    fi

}

__repacd_update_bh_ap_status() {

local hop_limit_disable=`/bin/config get hop_limit_disable`

if [ "$hop_limit_disable" -eq "1"  ]; then
    return
fi


backhaul_ap_5g=`/bin/config get wl5g_BACKHAUL_AP`
 
backhaul_ap_2g=`/bin/config get wl2g_BACKHAUL_AP`

backhaul_sta_5g=`/bin/config get wl5g_BACKHAUL_STA`

local hop_limit_cnt=`/bin/config get hop_limit_cnt`

if [ -z "$hop_limit_cnt" ]; then
    hop_limit_cnt=2
fi

whc_dist=`iwpriv $backhaul_sta_5g get_whc_dist | cut -d':' -f2`

if [ "$whc_dist" -lt "$hop_limit_cnt" ]; then
    backhaul_ap_5g_status=`ifconfig $backhaul_ap_5g | grep 'UP'`
    backhaul_ap_2g_status=`ifconfig $backhaul_ap_2g | grep 'UP'`
    if [ -z "$backhaul_ap_5g_status" ]; then
        __repacd_info "Bring 5G BH ap UP"
        ifconfig $backhaul_ap_5g up
    fi

    if [ -z "$backhaul_ap_2g_status" ]; then
        __repacd_info "Bring 2.4G BH ap UP"
        ifconfig $backhaul_ap_2g up
    fi
else
    backhaul_ap_5g_status=`ifconfig $backhaul_ap_5g | grep 'UP'`
    backhaul_ap_2g_status=`ifconfig $backhaul_ap_2g | grep 'UP'`
    if [ -n "$backhaul_ap_5g_status" ]; then
        __repacd_info "Bring 5G BH ap DOWN"
        ifconfig $backhaul_ap_5g down
    fi

    if [ -n "$backhaul_ap_2g_status" ]; then
        __repacd_info "Bring 2.4G BH ap DOWN"
        ifconfig $backhaul_ap_2g down
    fi
fi
}

__update_parentMac() {
    grep_range=15
    all_zero_mac="00:00:00:00:00:00"

    sleep 5
    if [ "$cur_role" = 'CAP' ]; then
        echo "`(echo td s2;sleep 2) | hyt | grep "Upstream Device:" | awk '{print $3}'`" > /tmp/hyt_result.txt
    else
        bh_sta_index=`/bin/config show | awk -F'=' '/BACKHAUL_STA/{print $2}'`
        hyt_result=$all_zero_mac

        for wlif_index in $bh_sta_index; do
            iw_info=`iwconfig $wlif_index`
            ap_mac=`echo $iw_info | grep -oE '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'`
            ap_mid_mac=`echo $ap_mac | cut -d : -f 2-5`

            if [ -z "$ap_mid_mac" ]; then
                echo "$wlif_index do not connect AP" > /tmp/."$wlif_index"_status
            else
                tmp_ap_mac="`cat /tmp/.iwconfig_"$wlif_index"`"
                result_of_hyt_file="`cat /tmp/hyt_result.txt`"

                if [ "$tmp_ap_mac" = "$ap_mac" -a "$result_of_hyt_file" != "$all_zero_mac" -a "$result_of_hyt_file" != "" ]; then
                    hyt_result="normal"
                    break
                else
                    hyd_mac=`(echo "td s2"; sleep 2)| hyt | grep -E "ath.*$ap_mid_mac" -B $grep_range | grep "#" | grep -oE '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'`
                    [ -z $hyd_mac ] || hyt_result=$hyd_mac
                    echo "$ap_mac" > /tmp/.iwconfig_"$wlif_index"
                fi
            fi
        done
        [ "x$hyt_result" != "xnormal" ] && echo "$hyt_result" > /tmp/hyt_result.txt
    fi
}


config_load repacd
config_get managed_network repacd 'ManagedNetwork' 'lan'
config_get cur_role repacd 'Role' 'NonCAP'
config_get link_check_delay repacd 'LinkCheckDelay' '2'
config_get dni_led_mode repacd 'DNI_Mode' '1'
config_get led_guardinterval repacd 'LED_GUARDINTERVAL' '120'
config_get daisy_chain WiFiLink 'DaisyChain' '0'
config_get traffic_separation_enabled repacd TrafficSeparationEnabled '0'
config_get traffic_separation_active repacd TrafficSeparationActive '0'
config_get backhaul_network repacd NetworkBackhaul 'backhaul'
config_get eth_mon_enabled repacd 'EnableEthernetMonitoring' '0'

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <start_role> <config RE mode> <current RE mode> [autoconf]"
    exit 1
fi

local wps_guardinterval=$(($led_guardinterval/$link_check_delay))

local start_role=$1
local config_re_mode=$2
local current_re_mode=$3
local current_re_submode=$4
local re_mode_change=0
local adjustment=6/10

local led_solid_times=$((180/$link_check_delay*$adjustment))
local boot_time=$((150/$link_check_delay*$adjustment))
local wps_guardinterval_times=0

local solid_times=0
local blink_times=0

local off_times=0
local wps_progress=0
local last_associated=0
local wps_fh_improgress=0
local IPLease_time=0
local IPLease_timeout=$((30/$link_check_delay*$adjustment))
local board_data=`/sbin/artmtd -r board_data | awk '{print $3}' |cut -b1-2`
local dns_hijack=`/bin/config get dns_hijack`
local ADD_ON_default=0
local time_counter=0

# Clean up the background ping and related logic when being terminated
# by the init system.
trap 'repacd_wifimon_fini; repacd_led_set_states Reset; exit 0' SIGTERM

__repacd_info "Starting: ConfiguredRole=$cur_role StartRole=$start_role"
__repacd_info "Starting: ConfigREMode=$config_re_mode CurrentREMode=$current_re_mode CurrentRESubMode=$current_re_submode"

local new_mode
__gwmon_init $cur_role $start_role $managed_network
new_mode=$?
if [ $eth_mon_enabled -eq 0 ] || [ ${new_mode} -ne $GWMON_MODE_NO_CHANGE ]; then
    __repacd_update_mode $new_mode
fi

local cur_state new_state
local new_re_mode=$current_re_mode new_re_submode=$current_re_submode
local autoconf_restart

# If the start was actually a restart triggered by automatic configuration
# logic (eg. mode or role switching), note that here so it can influence the
# LED states.
if [ -n "$5" ]; then
    __repacd_info "Startup triggered by auto-config change"
    autoconf_restart=1
else
    autoconf_restart=0
fi

if [ ! $eth_mon_enabled -eq 0 ]; then
    repacd_lp_init
    repacd_netdet_init
fi

if [ "$traffic_separation_enabled" -gt 0 ] && \
   [ "$traffic_separation_active" -gt 0 ]; then
    repacd_wifimon_init $backhaul_network $current_re_mode $current_re_submode $autoconf_restart \
                        new_state new_re_mode new_re_submode
else
    repacd_wifimon_init $managed_network $current_re_mode $current_re_submode $autoconf_restart \
                        new_state new_re_mode new_re_submode
fi

# Since the Wi-Fi monitoring process does nothing when in CAP mode, force
# the state to one that indicates we are operating in CAP mode.
if [ "$cur_role" = 'CAP' ]; then
    new_state='InCAPMode'
fi

if [ -n "$new_state" ]; then
    __repacd_info "Setting initial LED states to $new_state"
    repacd_led_set_states $new_state
    cur_state=$new_state
else
    __repacd_info "Failed to resolve STA interface; will attempt periodically"
fi

if [ "$board_data" -eq "00" -a "$dns_hijack" -eq "1" ]; then
    __repacd_info "ADD-ON default boot"
    ADD_ON_default=1
fi

# init sateliite GUI connection status file
local role=`uci get repacd.repacd.Role`
if [ "$role" = "CAP" ]; then
	echo "1" >/tmp/link_status_eth
else
	echo "0" >/tmp/link_status_eth
fi

# Loop forever (unless we are killed with SIGTERM which is handled above).
while true; do
    __gwmon_check
    new_mode=$?
	[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! Repacd run, get gateway mode: $new_mode" > /dev/console
	__repacd_update_mode $new_mode

    if [ -n "$cur_state" ]; then
        new_state=''
        repacd_wifimon_check $managed_network $current_re_mode $current_re_submode \
                             new_state new_re_mode new_re_submode

        # First test for range extender mode change, which could also include
        # a role change if the LED state is updated to indicate that.
        re_mode_change=0
        if [ "$config_re_mode" = 'auto' -a \
             ! "$current_re_mode" = "$new_re_mode" ]; then
            __repacd_info "New auto-derived RE mode=$new_re_mode"

            uci_set repacd repacd AssocDerivedREMode $new_re_mode
            uci_set repacd WiFiLink BSSIDResolveState 'resolving'
            uci_commit repacd

            re_mode_change=1
        fi
        # RE sub-mode change check.
        if [ ! "$current_re_submode" = "$new_re_submode" ]; then
            __repacd_info "New auto-derived RE sub-mode=$new_re_submode"

            uci_set repacd repacd AssocDerivedRESubMode $new_re_submode
            uci_commit repacd

            # As of now, no special handling required for "star" and "daisy" submodes.
            # So just keep the Current and New RE-submode in sync.
            current_re_submode=$new_re_submode
        fi



        if [ -n "$new_state" -a ! "$new_state" = "$cur_state" ]; then

            if [ "$dni_led_mode" = "0" ]; then
                __repacd_info "Updating LED states to $new_state"
                repacd_led_set_states $new_state
            fi

            cur_state=$new_state

            solid_times=0
            if [ "$blink_times" -gt 0 -a "$cur_state" = "Measuring" ]; then
                blink_times=1
            else
                blink_times=0
            fi

            off_times=0

            # Depending on the startup role, look for the special states
            # that indicate the new role should be different.
            if [ ! "$start_role" = 'RE' ]; then  # init and NonCAP roles
                if [ "$new_state" = $WIFIMON_STATE_CL_ACTING_AS_RE ]; then
                    __repacd_info "Restarting in RE role"
                    __repacd_restart 're'
                    re_mode_change=0  # role change includes mode change
                fi
            elif [ "$start_role" = 'RE' ]; then
                if [ "$new_state" = $WIFIMON_STATE_CL_LINK_INADEQUATE -o \
                     "$new_state" = $WIFIMON_STATE_CL_LINK_SUFFICIENT ]; then
                    __repacd_info "Restarting in Client role"
                    __repacd_restart 'noncap'
                    re_mode_change=0  # role change includes mode change
                fi
            fi
        fi

        if [ "$dni_led_mode" = "1" ]; then

            __repacd_info "$cur_state"


            case $cur_state in
                "RE_MoveFarther")
		    wps_guardinterval_times=0
                    ADD_ON_default=0

                    if [ $boot_time -gt 0 ]; then
                        boot_time=0
                    fi

                    if [ $solid_times -eq 0 -a "$last_associated" -eq 0 ]; then
                        __repacd_info "LED STATE--$cur_state"
                        #dni_led_set_states $cur_state
                        solid_times=$(($solid_times+1))
                        led_solid_times=$((180/$link_check_delay))
                        last_associated=1
                    fi

                    if [ "$led_solid_times" -gt 0 ]; then
                        led_solid_times=$(($led_solid_times - 1))

                       if [ "$led_solid_times" -eq 0 ]; then
                           __repacd_info "LED timeout"
                       fi

                    fi


                ;;

                "RE_LocationSuitable")
		    wps_guardinterval_times=0
                    ADD_ON_default=0

                    if [ $boot_time -gt 0 ]; then
                        boot_time=0
                    fi

                    if [ $solid_times -eq 0 -a "$last_associated" -eq 0 ]; then
                        __repacd_info "LED STATE--$cur_state"
                        #dni_led_set_states $cur_state
                        solid_times=$(($solid_times+1))
                        led_solid_times=$((180/$link_check_delay))
                        last_associated=1
                    fi

                    if [ "$led_solid_times" -gt 0 ]; then
                        led_solid_times=$(($led_solid_times - 1))
                        __repacd_info "LED SOLID TIMES--$led_solid_times"
                       if [ "$led_solid_times" -eq 0 ]; then
                           __repacd_info "LED timeout"
                       fi

                    fi
                ;;

                "RE_MoveCloser")
		    wps_guardinterval_times=0
                    ADD_ON_default=0

                    if [ $boot_time -gt 0 ]; then
                        boot_time=0
                    fi

                    if [ $solid_times -eq 0 -a "$last_associated" -eq 0 ]; then
                        __repacd_info "LED STATE--$cur_state"
                        #dni_led_set_states $cur_state
                        solid_times=$(($solid_times+1))
                        led_solid_times=$((180/$link_check_delay))
                        last_associated=1
                    fi

                    if [ "$led_solid_times" -gt 0 ]; then
                        led_solid_times=$(($led_solid_times - 1))

                       if [ "$led_solid_times" -eq 0 ]; then
                           __repacd_info "LED timeout"
                           #dni_led_set_states "OFF"
                       fi

                    fi

                ;;

                "Measuring")
                    wps_progress=0
                ;;

                "AssocTimeout")
                ;;

                "NotAssociated")
                    if [ "$ADD_ON_default" -eq "1" ]; then
                        __repacd_info "ADD-ON default boot"
                        boot_time=0
                        if [ "$solid_times" -eq 0 -a repacd_wifimon_check_wifi_ready ]; then
                            __repacd_info "Set ADD-ON default boot"
                            #dni_led_set_states "ADD-ON-default"
                            solid_times=1
                        fi

                    elif [ "$wps_guardinterval_times" -gt 0 ]; then
                        __repacd_info "WPS Guard Interval ::: $wps_guardinterval_times "
                    elif [ "$boot_time" -gt 0 ]; then
                        if [ "$blink_times" -eq 0 ]; then
                            #dni_led_set_states "Booting"
                            blink_times=1
                        fi
                    elif [ "$solid_times" -eq 0 -a "$wps_progress" -eq 0 ]; then
                        __repacd_info "LED STATE--$cur_state"
                        #dni_led_set_states $cur_state
                        solid_times=1
                    fi
                    last_associated=0
                ;;

                "AutoConfigInProgress")
                    wps_progress=1
                    ADD_ON_default=0
                    boot_time=0

                    if [ $last_associated -eq 1 ]; then
                        wps_fh_improgress=1
                        __repacd_info "FH WPS START"
                    fi

                ;;

                "AutoConfigFinish")
                    wps_progress=0
                    if [ $wps_fh_improgress -eq 1 ]; then
                        #dni_led_set_states "OFF"
                        wps_fh_improgress=0
                        __repacd_info "FH WPS FINISH"
                    else
                        wps_guardinterval_times=$wps_guardinterval
                    fi
                ;;

                "AutoConfigFail")
                    wps_progress=0
                    __repacd_info "WPS FAIL"
                    if [ $wps_fh_improgress -eq 1 ]; then
                        #dni_led_set_states "OFF"
                        wps_fh_improgress=0
                        __repacd_info "FH WPS FAIL"
                    fi

                ;;

                "OneBackhaulWPSInProgress")
                    __repacd_info "OneBackhaulWPSInProgress"
                ;;

                "OneBackhaulWPSTimeout")
                    __repacd_info "OneBackhaulWPSTimeout"
                ;;

                "IPLeaseFail")
                    __repacd_info "IPLeaseFail"
                    boot_time=0

                    if [ "$IPLease_time" -lt "$IPLease_timeout" ]; then
                        IPLease_time=$(($IPLease_time+1))
                        __repacd_info "IPLeaseFail ::: try $IPLease_time times"
                   
                        if [ "$IPLease_time" -eq "$IPLease_timeout" ]; then
                            __repacd_info "IPLease TIMEOUT"
                            #dni_led_set_states "IPLeaseFail"
                            last_associated=0
                        fi
                    fi

                ;;


            esac

        fi

        # Handle any RE mode change not implicitly handled above.
        if [ "$re_mode_change" -gt 0 ]; then
            if [ ! "$start_role" = 'RE' ]; then  # init and NonCAP roles
                __repacd_restart 'noncap'
            elif [ "$start_role" = 'RE' ]; then
                __repacd_restart 're'
            fi
        fi
        # if restart_wifi and re_mode_change is not start
        # go to determing if 2.4G backhaul interface need to down or not
        if [ "$restart_wifi" -eq 0 ]; then
            if [ "$re_mode_change" -eq 0 ]; then
                repacd_wifimon_independent_channel_check
            fi
        fi
    else
        repacd_wifimon_init $managed_network $current_re_mode $current_re_submode $autoconf_restart \
                            new_state new_re_mode new_re_submode
        if [ -n "$new_state" ]; then
            __repacd_info "Setting initial LED states to $new_state"
            repacd_led_set_states $new_state
            cur_state=$new_state
        fi
    fi

    if [ $eth_mon_enabled -eq 1 ]; then
        repacd_ethmon_check
    fi

    # Re-check the link conditions in a few seconds.

    if [ $boot_time -gt 0 ]; then
        boot_time=$(($boot_time - $link_check_delay))
    fi
    if [ $wps_guardinterval_times -gt 0 ]; then
        wps_guardinterval_times=$(($wps_guardinterval_times - 1))
    fi

    __repacd_info "Boot time count=$boot_time"
    #__repacd_update_bh_ap_status

    # wsplcd restart between disconnection and connection
    #if wsplcd sync, after wiating 10s
    if [ -f /tmp/.wsplcd_sync.lock ]; then
        sleep 10
        rm -f /tmp/.wsplcd_sync.lock
    fi

    __repacd_check_associated $bh_24g_iface $bh_5g_iface
    if  [ $associate_state -eq 0 ] || [  $lock_key_2G -eq 1 ]; then        # For only 2.4G or 5G connection
        lock_key_2G=1
        if [ "$associate_state" -gt "0" ]; then
            lock_key_2G=0
            /etc/init.d/wsplcd restart
        fi
    elif [ $associate_state -eq 2 ] || [ $lock_key_5G -eq 1 ]; then        # For 5G and 2.4G connection
        lock_key_5G=1
        if [ "$associate_state" -eq "1" ]; then
            lock_key_5G=0
            /etc/init.d/wsplcd restart
        fi
    fi

	[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! repace while sleep time is $link_check_delay" > /dev/console
	if [ "$time_counter" = "15" ]; then
		time_counter=0;
		__update_parentMac &
	fi
	time_counter=$(($time_counter+1))
    sleep $link_check_delay
done
