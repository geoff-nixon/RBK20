#!/bin/sh
# According to Orbi Desktop LED Definition Revise V1.1_0920.pptx
# and Orbi Additional Miscellaneous V1.3.pptx from Netgear

LED_DEBUG_OUTPUT=1
SLEEPTIME=2
LED_CTRL_PIPE_NAME='/var/run/led_ctrl.pipe'
. /lib/functions/repacd-led.sh
. /lib/functions.sh

# State information
local board_data=`/sbin/artmtd -r board_data | awk '{print $3}' | cut -b1-2`
local dns_hijack=`/bin/config get dns_hijack`
local conn_base=`/bin/config get conn_base`
local STATE_CHANGE=0

local ping_running=0 last_ping_gw_ip
local fail_time=0

local act_start_time
local wps_start_time
local add_on_duration=240
local state_duration=180
#local normal_duration=2
local cur_state=''
local pre_state=''

local bh_5g_iface=`/bin/config get wl5g_BACKHAUL_STA`
local bh_24g_iface=`/bin/config get wl2g_BACKHAUL_STA`

local bh_5g_rssi=0
local bh_24g_rssi=0
local bh_5g_rssi_th=`/bin/config get rssi_move_far5g`
local bh_24g_rssi_th=`/bin/config get rssi_move_far2g`



# Print DEBUG message
led_debug(){
    local stderr=''
    if [ "$LED_DEBUG_OUTPUT" -gt 0 ]; then
        stderr='-s'
    fi
    logger $stderr -t led_function "$1"
}


# Measure the RSSI of backhaul iface
# input: $1 iface
# output: $2 RSSI
led_bh_rssi(){
    local sta_iface=$1
    local bh_rssi=0

    bh_rssi=`iwconfig $sta_iface | grep 'Signal level' | awk -F'=' '{print $3}' | awk '{print $1}'`
    eval "$2=$bh_rssi"
}


# Determine if the STA interface named is current associated and active.
led_iface_is_assoc(){
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


# Determine if a provided amount of time has elapsed.
# input: $1 - start_time: the timestamp (in seconds)
# input: $2 - duration: the amount of time to check against (in seconds)
# return: 0 on timeout; non-zero if no timeout
led_is_timeout() {
    local start_time=$1
    local duration=$2

    # Check if the amount of elapsed time exceeds the timeout duration.
    local cur_time
    led_get_timestamp cur_time
    local elapsed_time=$(($cur_time - $start_time))
    led_debug "led check timeout elapsed:$elapsed_time duration:$duration"

    if [ "$elapsed_time" -gt $duration ]; then
         return 0

    fi

    return 1

}


# Obtain a timestamp from the system.
#
# These timestamps will be monontonically increasing and be unaffected by
# any time skew (eg. via NTP or manual date commands).
#
# output: $1 - the timestamp as an integer (with any fractional time truncated)
led_get_timestamp() {
    timestamp=`cat /proc/uptime | cut -d' ' -f1 | cut -d. -f 1`
    eval "$1=$timestamp"
}


# Start a background ping to the gateway address (if it can be resolved).
# This helps ensure the RSSI values are updated (as firmware will not report
# updates if only beacons are being received on the STA interface).
# input: $1 - network: the name of the network being managed
# return: 0 if the ping was started or is already running; otherwise 1
led_start_ping() {
    gw_ip=`route -n | grep ^0.0.0.0 | grep br0 | awk '{print $2}'`
    if [ -n "$gw_ip" ]; then
        if [ ! "$gw_ip" = "$last_ping_gw_ip" ]; then
            # First need to kill the existing one due to the IP change.
            led_stop_ping
            # This will leave ping_running set to 0.
        fi

        if [ "$ping_running" -eq 0 ]; then
            led_debug "Pinging GW IP $gw_ip"
            # Unfortunately the busybox ping command does not support an
            # interval. Thus, we can only ping once per second so there will
            # only be a handful of measurements over the course of our RSSI
            # sampling.
            ping $gw_ip > /dev/null &
            echo $! > /tmp/.led_ping
            ping_running=1
            last_ping_gw_ip=$gw_ip
        fi
        # Ping is running now or was started.
        return 0
    fi

    led_debug "Failed to resolve GW when starting ping; will re-attempt"
    return 1
}


# Terminate any background ping that may be running.
# If no background pings are running, this will be a nop.
led_stop_ping() {
    if [ "$ping_running" -gt 0 ]; then
        local child_id=$(cat /tmp/.led_ping)
        kill "$child_id"
        ping_running=0
        led_debug "Stopped ping to GW IP $last_ping_gw_ip"
    fi
}


led_wps_check(){
    local process_logged
    local inprocess
    local wps_pbc
    local wps_event
    local pipe_empty=0
    local delay=0
    # Check the status of the Wi-Fi link (WPS)
    for pipe_empty in 0
    do
        read -t 1 wps_pbc <>$LED_CTRL_PIPE_NAME
        pipe_empty=$?
        wps_event=$wps_pbc
        led_debug "WPS CHECK LOOP:$pipe_empty wps:$wps_event "
    done

    if [ "$wps_event" = "wps_pbc" ]; then
        led_debug "WPS START"
        inprocess=1
        process_logged=0
        /sbin/led_ring start white

    elif [  "$wps_event" = "wps_finish" ]; then
        led_debug "WPS FINISH"
        inprocess=0
        process_logged=1
        delay=1
        /sbin/led_ring stop

    elif  [  "$wps_event" = "wps_fail" ]; then
        led_debug "WPS FAIL"
        inprocess=0
        process_logged=1
        if [ $cur_state = "IPLeaseFail" ]; then
	         pre_state=''
        fi
        /sbin/led_ring stop
    fi

    eval "$1=$inprocess"
    eval "$2=$process_logged"
    eval "$3=$delay"
}


# Create ourselves a named pipe so we can be informed of WPS push
# button events.
if [ -e $LED_CTRL_PIPE_NAME ]; then
    rm -f $LED_CTRL_PIPE_NAME
fi

mkfifo $LED_CTRL_PIPE_NAME




# Turn on state
local var=true
local connect_time=0
local flag_addon=0
led_get_timestamp act_start_time
/sbin/led_ring start white

# Check wether is ADD-ON or not
# In this state, device will stay white when wireless is ready
if [ "$board_data" -eq "00" ] && [ -z "$conn_base"  ]; then
    led_debug "ADD-ON default boot"
    while $var
    do
        bh_5g_iface=`/bin/config get wl5g_BACKHAUL_STA`
        bh_24g_iface=`/bin/config get wl2g_BACKHAUL_STA`

        if [ -n $bh_5g_iface  ] || [ -n $bh_24g_iface ]; then
            if ! led_iface_is_assoc $bh_5g_iface; then
                led_debug "ADD-ON : BH5G IS NOT ASSOC"
                cur_state="Ready"
                led_debug "CUR $cur_state"
                if [ "$pre_state" != "$cur_state" ]; then
                    /sbin/led_ring stop
                    dni_led_set_states "ADD-ON-default"
                    pre_state=$cur_state
                    led_debug "PRE $pre_state CUR $cur_state"
                fi
            elif ! led_iface_is_assoc $bh_24g_iface; then
                led_debug "ADD-ON : BH24G IS NOT ASSOC"
                cur_state="Ready"
                led_debug "CUR $cur_state"
                if [ "$pre_state" -eq "$cur_state" ]; then
                    /sbin/led_ring stop
                    dni_led_set_states "ADD-ON-default"
                    pre_state=$cur_state
                    led_debug "PRE $pre_state CUR $cur_state"
                fi
            fi
        fi

        if led_iface_is_assoc $bh_5g_iface ; then
            led_debug "BH5G IS ASSOC"
            if [ $connect_time -gt 2 ]; then
                flag_addon=1
                add_on_process_logged=1
            fi
            connect_time=$(($connect_time+1))
        elif led_iface_is_assoc $bh_24g_iface ; then
            led_debug "BH24G IS ASSOC"
            if [ $connect_time -gt 2 ]; then
                flag_addon=1
                add_on_process_logged=1
            fi
            connect_time=$(($connect_time+1))
        fi

        if led_start_ping ; then
            led_debug "Ethernet IS ASSOC"
            var=false
        fi

        led_wps_check wps_inprocess add_on_process_logged wps_1st_finish
        led_debug "wps_inprocess $wps_inprocess add_on_process_logged $add_on_process_logged wps_1st_finish $wps_1st_finish"
        if [ "x$add_on_process_logged" = "x1" ]; then
            var=false
        fi

        sleep 2
    done
fi


# Normal bundle or configurated start
# Soild white 5 sec, then pulse white for 4 min
#/sbin/led_ring stop
/sbin/ledcontrol -n all -s off
#/sbin/ledcontrol -n all -c white -s ring
/sbin/led_ring start white
while $var;
do
   # /sbin/led_ring stop
   # /sbin/ledcontrol -n all -c white -s ring

    if led_is_timeout $act_start_time 240; then
        var=false
    fi

    bh_5g_iface=`/bin/config get wl5g_BACKHAUL_STA`
    bh_24g_iface=`/bin/config get wl2g_BACKHAUL_STA`

    if led_iface_is_assoc $bh_5g_iface ; then
        led_debug "BH5G IS ASSOC"
        if [ $connect_time -gt 2 ]; then
            var=false
        fi
        connect_time=$(($connect_time+1))
    elif led_iface_is_assoc $bh_24g_iface ; then
        led_debug "BH24G IS ASSOC"
        if [ $connect_time -gt 2 ]; then
            var=false
        fi
        connect_time=$(($connect_time+1))
    fi

    if led_start_ping ; then
        led_debug "Ethernet IS ASSOC"
        var=false
    fi

    if led_start_ping ; then
        led_debug "Ethernet IS ASSOC"
        var=false
    fi

    sleep 2
done

/sbin/led_ring stop


# LED main function
while true; do
    bh_5g_iface=`/bin/config get wl5g_BACKHAUL_STA`
    bh_24g_iface=`/bin/config get wl2g_BACKHAUL_STA`

        #Check the status of the Wi-Fi link(associate, RSSI)
    if  led_iface_is_assoc $bh_5g_iface ; then

        for i in `seq 1 1 3`
        do
            led_bh_rssi $bh_5g_iface bh_5g_rssi
            sleep 1
        done

        if [ "$bh_5g_rssi" -ge "$bh_5g_rssi_th" ]; then
            led_debug "RSSI5G $bh_5g_rssi"
            cur_state="RE_LocationSuitable"
        else
            led_debug "RSSI5G $bh_5g_rssi"
            cur_state="RE_MoveCloser"
        fi
    elif  led_iface_is_assoc $bh_24g_iface ; then

        for i in `seq 1 1 3`
        do
            led_bh_rssi $bh_24g_iface bh_24g_rssi
            sleep 1
        done

        if [ "$bh_24g_rssi" -ge "$bh_24g_rssi_th" ]; then
            led_debug "RSSI24G $bh_24g_rssi"
            cur_state="RE_LocationSuitable"
        else
            led_debug "RSSI24G $bh_24g_rssi"
            cur_state="RE_MoveCloser"
        fi
    else
            cur_state="NotAssociated"
    fi

    #Check the statues of ethernet link
    if  [ "x`/sbin/uci get repacd.repacd.Role`" = "xCAP" ];then
        cur_state="Ethernet_Connect"
    fi

    # Check network state
    # Whether the IP is lease or not during 30 sec
    config_get network wifi-iface network
    if led_start_ping $network; then
        led_debug "PING IS WELL"
        fail_time=0
    else
        if [ "$fail_time" -eq 0 ]; then
            led_debug "FIRST PING FAIL!!"
            led_get_timestamp pingFailtime_start
            fail_time=$(($fail_time + 1 ))
        else
            if led_is_timeout $pingFailtime_start 30; then
                cur_state="IPLeaseFail"
                led_debug "CUR_STATE $cur_state"
                led_debug " ==IP can not PING=="
            fi
        fi
    fi

    # Check WPS state
    led_wps_check wps_inprocess wps_process_logged wps_1st_finish
    led_debug "wps_inprocess $wps_inprocess wps_process_logged $wps_process_logged wps_1st_finish $wps_1st_finish"
    if [ "x$wps_1st_finish" = "x1" ] || [ "x$flag_addon" = "x1" ]; then
        flag_addon=0
        led_get_timestamp wps_delay_start
        led_debug "CONNECTED"

        # Wait for WPS state stable
        sleep 10
        dni_led_set_states RE_LocationSuitable
        led_debug "WPS DELAY START"
        sleep 50
    fi

    allconfig_flag=`cat /tmp/allconfig_flag 2>/dev/null`
    if [ "x$allconfig_flag" = "x2" ]; then
        echo "0" > /tmp/allconfig_flag
        dni_led_set_status RE_LocationSuitable
        cur_state="RE_LocationSuitable"
        pre_state=$cur_state
        sleep 240
    fi

    if [ "$cur_state" != "$pre_state" ]; then
        if led_start_ping $network; then
            led_debug " NO NEED TO RESART TIMER"
        else
            led_debug "CUR $cur_state PRE $pre_state"
            led_get_timestamp act_start_time
        fi
    fi

    # Check whether the state is timeout or not
    if  led_is_timeout $act_start_time $state_duration; then
        loop_begin=0
        led_debug "SELECTION LOOP CONTINUE"
        #if [ "$cur_state" != "NotAssociated" ] || [ "$cur_state" != "IPLeaseFail" ]; then
        if [ "$cur_state" != "IPLeaseFail" ]; then
            #/sbin/led_ring stop
            /sbin/ledcontrol -n all -s off
            led_debug " CUR_STATE: $cur_state"
        fi
    else
        if led_start_ping $network; then
            led_debug " NO NEED TO CHANGE LIGHT"
        else
            loop_begin=1
            led_debug "SELECTION LOOP BEGIN"
        fi
    fi

    if [ "x$loop_begin" = "x1" -o "x$wps_process_logged" = "x1" ] ; then
        led_debug "SLECTION STATE $cur_state"
        case $cur_state in
            "RE_MoveFarther")
            ;;

            "RE_LocationSuitable")
                if [ "$cur_state" != "$pre_state" ] && [ "$pre_state" != "RE_MoveCloser" ]; then
                    led_get_timestamp act_start_time
                    #state_duration=$normal_duration
                    led_debug "RE_LocationSuitable_duration= $state_duration"
                    led_debug "Suitable START $act_start_time "
                    dni_led_set_states $cur_state
                    led_debug "LED RE_LocationSuitable"

                    pre_state=$cur_state
                fi
            ;;

            "Ethernet_Connect")
                if [ "$cur_state" != "$pre_state" ]; then
                    led_get_timestamp act_start_time
                    #state_duration=$normal_duration
                    led_debug "Ethernet_Connect_duration= $state_duration"
                    led_debug "Suitable START $act_start_time "
                    dni_led_set_states $cur_state

                    pre_state=$cur_state
                fi
            ;;

            "RE_MoveCloser")
                if [ "$cur_state" != "$pre_state" ] && [ "$pre_state" != "RE_LocationSuitable" ]; then
                    led_get_timestamp act_start_time
                    led_debug "RE_MoveCloser_duration= $state_duration"
                    led_debug "RE_MoveCloser START $act_start_time "
                    dni_led_set_states $cur_state
                    led_debug "LED RE_MoveCloser"

                    pre_state=$cur_state
                fi
            ;;


            "Measuring")
            ;;

            "AssocTimeout")
            ;;

            "NotAssociated")
                if [ "$cur_state" != "$pre_state" ]; then
                    led_get_timestamp act_start_time
                    #state_duration=$normal_duration
                    led_debug "NotAssociated_duration_duration= $state_duration"
                    led_debug "NotAssociated_duration= START $act_start_time "
                    dni_led_set_states $cur_state
                    led_debug "LED NotAssociated_duration "

                    pre_state=$cur_state
                fi
            ;;

            "AutoConfigInProgress")
            ;;

            "AutoConfigFinish")
            ;;

            "AutoConfigFail")
            ;;

            "OneBackhaulWPSInProgress")
            ;;

            "OneBackhaulWPSTimeout")
            ;;

            "IPLeaseFail")
                if [ "$cur_state" != "$pre_state" ]; then
                    led_get_timestamp act_start_time
                    #state_duration=$normal_duration
                    led_debug "IPLeaseFail_duration_duration= $state_duration"
                    led_debug "IPLeaseFail_duration= START $act_start_time "
                    dni_led_set_states $cur_state
                    led_debug "LED IPLeaseFail_duration"

                    pre_state=$cur_state
                fi
            ;;


        esac

    fi

    sleep "$SLEEPTIME"

    led_debug "========LOOP END========="
done

