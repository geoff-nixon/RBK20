#!/bin/sh

# Copyright (c) 2015-2018 Qualcomm Technologies, Inc.
# All Rights Reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.
#
# 2015-2016 Qualcomm Atheros, Inc.
## All Rights Reserved.
# Qualcomm Atheros Confidential and Proprietary.

GWMON_DEBUG_OUTOUT=0
GWMON_SWITCH_CONFIG_COMMAND=swconfig

GWMON_MODE_NO_CHANGE=0
GWMON_MODE_CAP=1
GWMON_MODE_NON_CAP=2

. /lib/functions.sh
. /lib/functions/hyfi-iface.sh
. /lib/functions/hyfi-network.sh

local prev_gw_link router_detected=0 gw_iface="" gw_switch_port=""
local managed_network switch_iface="" vlan_group="" switch_ports
local cpu_portmap=0
local eswitch_support="0"
last_hop_count=255
wlan_updown_lockfile=/tmp/.wlan_updown_lockfile

# Emit a log message
# input: $1 - level: the symbolic log level
# input: $2 - msg: the message to log
__gwmon_log() {
    local stderr=''
    if [ "$GWMON_DEBUG_OUTOUT" -gt 0 ]; then
        stderr='-s'
    fi

    logger $stderr -t repacd.gwmon -p user.$1 "$*"
}

# Emit a log message at debug level
# input: $1 - msg: the message to log
__gwmon_debug() {
    __gwmon_log 'debug' $1
}

# Emit a log message at info level
# input: $1 - msg: the message to log
__gwmon_info() {
    __gwmon_log 'info' $1
}

# Emit a log message at warning level
# input: $1 - msg: the message to log
__gwmon_warn() {
    __gwmon_log 'warn' $1
}

__gwmon_find_switch() {
    local vlan_grp

    #Ignore value returned by eswitch_support in repacd. It is to be used by hyd only. 
    __hyfi_get_switch_iface switch_iface eswitch_support

    if [ -n "$switch_iface" ]; then
        $GWMON_SWITCH_CONFIG_COMMAND dev switch0 set flush_arl 2>/dev/null
        vlan_grp="`echo $switch_iface | awk -F. '{print $2}' 2>/dev/null`"
    fi

    if [ -z "$vlan_grp" ]; then
        vlan_group="1"
    else
        vlan_group="$vlan_grp"
    fi
}

__gwmon_get_switch_ports() {
    local local config="$1"
    local vlan_group="$2"
    local ports vlan cpu_port __cpu_portmap

    config_get vlan "$config" vlan
    config_get ports "$config" ports

    [ ! "$vlan" = "$vlan_group" ] && return

    cpu_port=`echo $ports | awk '{print $1}'`
    ports=`echo $ports | sed 's/'$cpu_port' //g'`
    eval "$3='$ports'"

    cpu_port=`echo $cpu_port | awk -Ft '{print $1}'`

    case $cpu_port in
        0) __cpu_portmap=0x01;;
        1) __cpu_portmap=0x02;;
        2) __cpu_portmap=0x04;;
        3) __cpu_portmap=0x08;;
        4) __cpu_portmap=0x10;;
        5) __cpu_portmap=0x20;;
        6) __cpu_portmap=0x40;;
        7) __cpu_portmap=0x80;;
    esac
    eval "$4='$__cpu_portmap'"
}

__gwmon_set_hop_count() {
    local config=$1
    local iface mode

    config_get mode "$config" mode
    config_get iface $config ifname

    if [ "$mode" = "ap" ]; then
        __gwmon_info "Setting intf [$iface] hop count $2"
        iwpriv $iface set_whc_dist $2
    fi
}

# Check MAC learning in ssdk_sh command with Port Status
__gwmon_check_mac_portstatus() {
    local sh_ssdk
    local sh_mac

    sh_mac="$(echo "$1" | sed 's/:/-/g')"
    sh_ssdk=$(ssdk_sh fdb entry show |grep  $sh_mac | awk -F':' '{print $5}')
    for port_tmp in $sh_ssdk
    do
        if [ "$port_tmp" -gt 0 ]; then
            gw_switch_port=$port_tmp
            return 0
        fi
    done
    return 1
}

# Check GW reachability over Ethernet backhaul,
# Set hop count correctly to prevent isolated island condition
__gwmon_prevent_island_loop() {
    local retries=3
    local gw_ip next_hop_count=255

    while [ "$retries" -gt 0 ]; do
        gw_ip=`route -n | grep ^0.0.0.0 | grep br$1 | awk '{print $2}'`
        [ -z "$gw_ip" ] && break
		[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! gwmon_prevent_island_loop: use route to get gw_ip: $gw_ip" > /dev/console	
        ping -W 2 $gw_ip -c1 > /dev/null

        # Ping returns zero if at least one response was heard from the specified host
        if [ $? -eq 0 ]; then
			[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! gwmon_prevent_island_loop: use ping to ping gateway $gw_ip success" > /dev/console
            __gwmon_debug "Ping to GW IP[$gw_ip] success"
            next_hop_count=1
            break
        else
            # no ping response was received, retry
            retries=$((retries -1))
			[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! gwmon_prevent_island_loop: ping gateway fail" > /dev/console
            __gwmon_debug "Ping to GW IP[$gw_ip] failed ($retries retries left)"
        fi
    done

    if [ $last_hop_count -ne $next_hop_count ]; then
		[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! gwmon_prevent_island_loop: Changing hop_count from $last_hop_count to $next_hop_count " > /dev/console
        __gwmon_info "Changing hop_count from $last_hop_count to $next_hop_count"
        config_load wireless
        config_foreach __gwmon_set_hop_count wifi-iface $next_hop_count
        last_hop_count=$next_hop_count
    fi
}

__gwmon_check_gw_iface_link() {
    local ret

    if [ "$gw_iface" = "$switch_iface" ]; then
        local link_status
    
        [ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! gateway iface is $gw_iface == switch iface $switch_iface" >/dev/console

        # Before we check local link status, make sure gw_iface (eth) is up
        ret=`ifconfig $gw_iface | grep UP[A-Z' ']*RUNNING`
        __gwmon_info "Checking ifconfig $gw_iface is up and running, ret= $ret"

        [ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! Checking ifconfig $gw_iface is up and running, ret= $ret"  > /dev/console

        [ -z "$ret" ] && prev_gw_link="down" && return 0

        link_status=$($GWMON_SWITCH_CONFIG_COMMAND dev switch0 port $gw_switch_port get link |awk -F':' '{print $3}'|awk -F ' ' '{print $1}')

        [ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! get gateway switch port $gw_switch_port's  link_status: $link_status" > /dev/console

        if [ ! "$link_status" = "up" ]; then
            link_status="down"
        fi

        if [ ! "$link_status" = "down" ]; then
            # link is up
            if [ ! "$prev_gw_link" = "up" ]; then
                [ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! previous link status is $prev_gw_link, so Link to GW UP" > /dev/console
                __gwmon_info "Link to GW UP"
                echo  "[repacd]Link to GW UP" >/dev/console
                prev_gw_link="up"
            fi
            # Check if GW is reachable, set appropriate hop count to avoid isolated island condition
            __gwmon_prevent_island_loop
            return 1
        fi
    else
        ret=`ifconfig $gw_iface | grep UP[A-Z' ']*RUNNING`
		[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! link status is $link_status, use ifconfig to see gateway if iface is running, ret is $ret" > /dev/console
         [ -n "$ret" ] && return 1
        [ -n "$ret" ] && return 1
    fi

    if [ ! "$prev_gw_link" = "down" ]; then
        __gwmon_info "Link to GW DOWN"
		[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! previous link status is $prev_gw_link, so Link to GW DOWN" > /dev/console
         echo  "[repacd]Link to GW DOWN" >/dev/console
        echo  "[repacd]Link to GW DOWN" >/dev/console
        prev_gw_link="down"
    fi
    return 0
}

# __gwmon_check_gateway
# input: $1 1905.1 managed bridge
# output: $2 Gateway interface
# returns: 1 if gateway is detected
__gwmon_check_gateway() {
    local gw_ip gw_mac gw_port __gw_iface
    local ether_ifaces_full ether_ifaces
    local ether_iface ret

    [ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!!Enthernet backhaul: check gateway, input parameter is bridge $1, Gateway interface $2" > /dev/console

    gw_ip=`route -n | grep ^0.0.0.0 | grep br$1 | awk '{print $2}'`
    [ -z "$gw_ip" ] && return 0

    [ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!!Enthernet backhaul: use route to get gateway ip: $gw_ip" > /dev/console

    ping -c 2 $gw_ip -c1 >/dev/null

    gw_mac=`cat /proc/net/arp | grep br$1 | grep "$gw_ip\b" |grep -v '00:00:00:00:00:00'| awk '{print $4}'`
    [ -z "$gw_mac" ] && return 0

    [ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!!Enthernet backhaul: use arp table to get gateway mac: $gw_mac" > /dev/console

    # Instead of using hyctl (which may not be installed if not running the
    # full Hy-Fi build), use brctl instead. One additional step of mapping
    # the port number to an interface name is needed though.
    gw_br_port=`brctl showmacs br$1 | grep -i $gw_mac | awk '{print $1}'`
    [ -z "$gw_br_port" ] && return 0

    [ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!!Enthernet backhaul: use arp table to get gateway port: $gw_br_port" > /dev/console

    __gw_iface=`brctl showstp br$1 | grep \($gw_br_port\) | awk '{print $1}'`
    [ -z "$__gw_iface" ] && return 0

    [ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!!Enthernet backhaul: use brctl show to get gateway eth face: $__gw_iface" > /dev/console

    # Get all Ethernet interfaces
    hyfi_get_ether_ifaces $1 ether_ifaces_full
    hyfi_strip_list $ether_ifaces_full ether_ifaces

    #workaround ,not allow hyfi_get_ether_ifaces get athx result
    if [ "`echo $ether_ifaces|grep ath`" != "" ];then
        return 0
    fi

    # Check if this interface belongs to our network
    for ether_iface in $ether_ifaces; do
        if [ "$ether_iface" = "$__gw_iface" ]; then
            gw_iface=$__gw_iface
            __gwmon_info "Detected Gateway on interface $gw_iface"
            [ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!!Find gateway eth face on $gw_iface" > /dev/console
            if [ "$ether_iface" = "$switch_iface" ]; then
                if ! __gwmon_check_mac_portstatus $gw_mac; then
                    __gwmon_warn "invalid port map portmap"
                    [ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!!Invalid port map: $portmap" > /dev/console
                    gw_switch_port=9
                    return 0
                fi
                __gwmon_info "gwmon_check_gateway Detected over ethernet =$gw_switch_port"
            fi
            __repacd_wifimon_bring_iface_down $sta_iface_5g
            __repacd_wifimon_bring_iface_down $sta_iface_24g
            return 1
        fi
    done

    # also check the loop prevention code to see if it believes we have
    # an upstream facing Ethernet interface
    local num_upstream=$(lp_numupstream)
    if [ ${num_upstream} -gt 0 ]; then
        [ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!!Check loop prevention code, num_upstream: $num_upstream" > /dev/console
		return 1
    fi

    return 0
}

# Check whether the configured mode matches the mode that is determined by
# checking for connectivity to the gateway.
#
# input: $1 cur_role: the current mode that is configured
# input: $2 start_mode: the mode in which the auto-configuration script is being
#                       run; This is used by the init script to help indicate
#                       that it was an explicit change into this mode.
#                       If the mode was CAP, then it should take some time
#                       before it is willing to switch back to non-CAP due
#                       to lack of a gateway.
# input: $3 managed_network: the logical name for the network interfaces to
#                            monitor
#
# return: value indicating the desired mode of operation
#  - $GWMON_MODE_CAP to act as the main AP
#  - $GWMON_MODE_NON_CAP to switch to being a secondary AP
#  - $GWMON_MODE_NO_CHANGE for now change in the mode
__gwmon_init() {
    local cur_mode=$1
    local start_mode=$2
	
	[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!!Enthernet backhaul: repacd gwmon init, start detect mode... current mode is $cur_mode, start mode is $start_mode" > /dev/console
    local ethernet_backhaul_disable=`/bin/config get ethernet_backhaul_disable`

    if [ "$ethernet_backhaul_disable" -eq "1"  ]; then
 	return $GWMON_MODE_NO_CHANGE
    fi

    managed_network=$3
    __gwmon_find_switch $managed_network
    [ -n "$switch_iface" ] && __gwmon_info "found switch on $switch_iface VLAN=$vlan_group"

    config_load repacd
    config_get eth_mon_enabled repacd 'EnableEthernetMonitoring' '0'

    config_load network
    config_foreach __gwmon_get_switch_ports switch_vlan $vlan_group switch_ports cpu_portmap
    __gwmon_info "switch ports in the $managed_network network: $switch_ports"
	[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "switch ports in the $managed_network network: $switch_ports" > /dev/console
    __gwmon_check_gateway $managed_network
    router_detected=$?

    if [ "$cur_mode" = "CAP" ]; then
        if [ "$router_detected" -eq 0 ]; then
            if [ $eth_mon_enabled -eq 0 ] && [ ! "$start_mode" = "CAP" ]; then
                return $GWMON_MODE_NON_CAP
            else
                local retries=3

                while [ "$retries" -gt 0 ]; do
                    __gwmon_check_gateway $managed_network
                    router_detected=$?
                    [ "$router_detected" -gt 0 ] && break
                    retries=$((retries -1))
                    __gwmon_debug "redetecting gateway ($retries retries left)"
                done

                # If gateway was still not detected after our attempts,
                # indicate we should change to non-CAP mode.
                if [ "$router_detected" -eq 0 ]; then
                    if [ $eth_mon_enabled -eq 0 ]; then
                        return $GWMON_MODE_NON_CAP
                    else
                        return $GWMON_MODE_NO_CHANGE
                    fi
                fi
            fi
        fi
    else   # non-CAP mode
        if [ "$router_detected" -eq 1 ]; then
            local mixedbh=$(uci get repacd.repacd.EnableMixedBackhaul 2>/dev/null)
            if [ "$mixedbh" != "1" ]; then
                return $GWMON_MODE_CAP
            fi
        fi
    fi

    return $GWMON_MODE_NO_CHANGE
}
#in ethernet backhaul,hop will be 0 after wireless restart,so need update it.
__gwmon_update_hop() {
	hop_count=`iwpriv ath0 get_whc_dist | awk -F ":" '{print $2}'|sed s/[[:space:]]//g`
	if [ ! -f $wlan_updown_lockfile -a  "x`uci get repacd.repacd.Role`" = "xCAP" -a "$hop_count" = "0" ]; then
		config_load wireless
		config_foreach __gwmon_set_hop_count wifi-iface 1
	fi
}


# return: 2 to indicate CAP mode; 1 for non-CAP mode; 0 for no change
__gwmon_check() {
    local config_changed=0
    local ethernet_backhaul_disable=`/bin/config get ethernet_backhaul_disable`

    if [ "$ethernet_backhaul_disable" -eq "1"  ]; then
		[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! ethernet_backhaul_disable is 1, return mode GWMON_MODE_NO_CHANGE $GWMON_MODE_NO_CHANGE" > /dev/console
        return $GWMON_MODE_NO_CHANGE
    fi

	__gwmon_update_hop

    if [ "$router_detected" -eq 0 ]; then
		[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! router_detected flag is 0, run into gateway check managed network is $managed_network" > /dev/console
		__gwmon_check_gateway $managed_network
        router_detected=$?

        if [ "$router_detected" -gt 0 ]; then
            local mixedbh=$(uci get repacd.repacd.EnableMixedBackhaul 2>/dev/null)
            # if we want to support mixed backhaul, e.g., if we want to
            # enable both WiFi and Ethernet backhaul, then we stay in
            # non-cap mode so the STA interfaces remain up.  otherwise,
            # set to cap mode which brings down the STA interfaces.
            if [ "$mixedbh" != "1" ]; then
				[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! mixedbh(repacd.repacd.EnableMixedBackhaul) is $mixedbh, /sbin/eth_handle restart return mode GWMON_MODE_CAP $GWMON_MODE_CAP"  > /dev/console
				/sbin/eth_handle restart &
                return $GWMON_MODE_CAP
            fi
        fi
    else
        __gwmon_check_gw_iface_link

        if [ "$?" -eq 0 ]; then
            # Gateway is gone
            router_detected=0
            gw_iface=""
            gw_switch_port=""
            /sbin/eth_handle restart &
			[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! gateway iface is gone, reset to default, /sbin/eth_handle restart return mode GWMON_MODE_NON_CAP $GWMON_MODE_NON_CAP" > /dev/console 
			return $GWMON_MODE_NON_CAP
        fi
    fi
	[ -n "$(/bin/config get ethernet_backhaul_debuglog)" ] && echo "!!!!! router_detected flag is $router_detected, return mode GWMON_MODE_NO_CHANGE $GWMON_MODE_NO_CHANGE" > /dev/console
    return $GWMON_MODE_NO_CHANGE
}
