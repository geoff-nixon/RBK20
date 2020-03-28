#!/bin/sh

DIR="/opt/bitdefender"
BIN_DIR="$DIR/bin"
LIB_DIR="$DIR/lib"

BOX_IPTABLES="$BIN_DIR/iptables"
ln -s /usr/sbin/iptables $BOX_IPTABLES 2> /dev/null

run() {
    LD_LIBRARY_PATH="$LIB_DIR:$LD_LIBRARY_PATH" $@
}

init_guster_chain() {
        # create empty GUSTER chain:
        $BOX_IPTABLES -N GUSTER 2> /dev/null
        # append it to BD_FILTER (the first rule in FORWARD will be a jump to BD_FILTER):
        $BOX_IPTABLES -C BD_FILTER -p tcp ! --dport 53 ! --sport 53 -j GUSTER >/dev/null 2>&1 || $BOX_IPTABLES -A BD_FILTER -p tcp ! --dport 53 ! --sport 53 -j GUSTER
}

uninit_guster_chain() {
        $BOX_IPTABLES -D BD_FILTER -p tcp ! --dport 53 ! --sport 53 -j GUSTER >/dev/null 2>&1
}

case "$1" in
    start)
        init_guster_chain
    ;;
    stop)
        uninit_guster_chain
    ;;
    *)
        init_guster_chain
        run ${BIN_DIR}/bdexchange-pump -t ":reinit_guster_chain" >/dev/null 2>&1
    ;;
esac
