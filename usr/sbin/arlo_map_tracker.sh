#!/bin/sh

arlo_list_path="/tmp/arlo/arlo_list"
fifo_path="/tmp/wifi-listener.fifo"
arp_table="/proc/net/arp"
static_arp_list_path="/tmp/static_arp_list"
bcst_code=1
arlo_iface=`config get wl2g_ARLO_AP`

# inform wifi-listener basic message and check file existence
inform_listener () {
    if [ ! -f "$arlo_list_path" ]; then
        echo "[ arlo ] arlo list not found" > /dev/console
        exit 0
    else
        echo "[ arlo ] arlo list exist" > /dev/console
        while read arlo_list; do
            echo "[ arlo ]$bcst_code-"${arlo_list// /-}" update to fifo" > /dev/console
            echo "$bcst_code-"${arlo_list// /-}"" > $fifo_path
            sleep 5
        done < $arlo_list_path
    fi
}

sync_staticARP_wlanlist () {

    cat /proc/net/arp | grep 0x6 | awk '{print $1 " " $4}' > $static_arp_list_path

    while read arlo_static; do

        arlo_ip=`echo $arlo_static | awk '{print $1}'`
        arlo_mac=`echo $arlo_static | awk '{print $2}'`

        arlo_mac_wlist_ck="`wlanconfig $arlo_iface list | grep "$arlo_mac"`"

        if [ -z "$arlo_mac_wlist_ck" ]; then
            echo "[ arlo ] $arlo_mac is not in  wlist" > /dev/console
            ip neigh del `echo "$arlo_ip dev brarlo lladdr $arlo_mac"`
            echo "[ arlo ] $arlo_mac static ARP entry has been deleted" > /dev/console
        fi

    done < $static_arp_list_path
    rm $static_arp_list_path
}


if [ $# -eq 0 ]; then
    if [ ! -f "$arlo_list_path" ]; then
        echo "[ arlo ] arlo list not found" > /dev/console
        sync_staticARP_wlanlist
        exit 0
    fi

    while read arlo_list; do
        arlo_mac=`echo $arlo_list | awk '{print $1}'`
        arlo_ip=`echo $arlo_list | awk '{print $2}'`
        arlo_mac_wlist_ck="`wlanconfig $arlo_iface list | grep "$arlo_mac"`"
        arlo_mac_arp_ck="`cat $arp_table | grep $arlo_mac`"
        arp_table_flag_ck="`echo $arlo_mac_arp_ck | awk '{print $3}' `"

        if [ -z "$arlo_mac_wlist_ck" ]; then
            echo "[ arlo ] $arlo_mac is not in  wlist" > /dev/console
            if [ -z "$arlo_mac_arp_ck" ]; then
                echo "[ arlo ] $arlo_mac is not on arp" > /dev/console
            else
                echo "[ arlo ] $arlo_mac is on arp" > /dev/console
                ip neigh del `echo "$arlo_ip dev brarlo lladdr $arlo_mac"`
                echo "[ arlo ] $arlo_mac ARP entry has been deleted" > /dev/console
            fi
        else
            echo "[ arlo ] $arlo_mac is in wlist" > /dev/console
            ip neigh del `echo "$arlo_ip dev brarlo lladdr $arlo_mac"`
            echo "[ arlo ] $arlo_mac ARP entry has been deleted" > /dev/console
            /sbin/arp -s $arlo_ip $arlo_mac
            echo "[ arlo ] $arlo_mac ARP entry has been set static ARP entry" > /dev/console
        fi
    done < $arlo_list_path
    inform_listener
else
    arlo_mac_arp_ck="`cat $arp_table | grep $1 `"
    MAC_ADDRESS=$1
    IP_ADDRESS=$2
    arp_table_flag_ck="`echo $arlo_mac_arp_ck | awk '{print $3}' `"

    echo "[ arlo ] check arlo mac : $1 , arlo ip : $2" > /dev/console
    
    if [  -z "`wlanconfig $arlo_iface list | grep $MAC_ADDRESS`" ]; then
        echo "[ arlo ] $MAC_ADDRESS is not in wlist." > /dev/console
        if [ -z "`cat /proc/net/arp | grep $MAC_ADDRESS`" ]; then
            echo "[ arlo ] $MAC_ADDRESS is not in arp table" > /dev/console
        else
            ip neigh del `echo "$IP_ADDRESS dev brarlo lladdr $MAC_ADDRESS"`
            echo "[ arlo ] $MAC_ADDRESS ARP entry has been deleted" > /dev/console
        fi
    else
        echo "[ arlo ] $MAC_ADDRESS is in wlist." > /dev/console
        ip neigh del `echo "$IP_ADDRESS dev brarlo lladdr $MAC_ADDRESS"`
        echo "[ arlo ] $MAC_ADDRESS ARP entry has been deleted" > /dev/console
        /sbin/arp -s $IP_ADDRESS $MAC_ADDRESS
        echo "[ arlo ] $MAC_ADDRESS ARP entry has been set static ARP entry" > /dev/console
    fi
fi


