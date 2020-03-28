#!/usr/bin/env sh

if [ $# -ge 1 ] && [ "${1}" = "-6" ]; then
    IPTABLES_CMD="ip6tables"
    ICMP_PORT_UNREACHABLE="icmp6-port-unreachable"
    TEST_IP="FE80::903A:1C1A:E802:11E4"
    TCP_IP_MIN_HLEN=60 # Fixed IPv6 header(40) + TCP header(20)
    # NOTE: this will only match IPv6 packets without extension headers
    U32_NO_PAYLOAD_MATCH="-m u32 --u32 3&0xff=6 -m u32 ! --u32 40@12>>26&0x3C@0>>24&0xFF=0:255"
    shift
else
    IPTABLES_CMD="iptables"
    ICMP_PORT_UNREACHABLE="icmp-port-unreachable"
    TEST_IP="127.42.42.42"
    TCP_IP_MIN_HLEN=40 # IP header(20) + TCP header(20)
    U32_NO_PAYLOAD_MATCH="-m u32 ! --u32 0>>22&0x3C@12>>26&0x3C@0>>24&0xFF=0:255"
fi

if [ $# -lt 1 ]; then
    echo "usage: $0 [-6] <first_queue> [last_queue]"
    exit
fi

FIRST_QUEUE=$1
LAST_QUEUE=$2

if [ -z $LAST_QUEUE ]; then
    QUEUE_CMD="--queue-num ${FIRST_QUEUE}"
else
    QUEUE_CMD="--queue-balance ${FIRST_QUEUE}:${LAST_QUEUE}"
fi

# Check the availability of the "--queue-bypass" argument
${IPTABLES_CMD} -A OUTPUT -d ${TEST_IP} -j NFQUEUE --queue-bypass && \
    QUEUE_CMD="${QUEUE_CMD} --queue-bypass"
${IPTABLES_CMD} -D OUTPUT -d ${TEST_IP} -j NFQUEUE --queue-bypass

# Workaround for a pre v2.6.39 kernel bug in "xt_conntrack.c" that switches the
# meaning of the REPLY and ORIGINAL ctdir parameters.
#
# The bug was eventually fixed in Linux kernel commit
#     96120d86 "netfilter: xt_conntrack: fix inverted conntrack direction test"
KERN_VER=$(uname -r)
if [ ! -z "${GC_CTDIR_ORIGINAL}" ]; then
    if [ "${GC_CTDIR_ORIGINAL}" != "ORIGINAL" ] && \
        [ "${GC_CTDIR_ORIGINAL}" != "REPLY" ]; then
    echo "Invalid GC_CTDIR_ORIGINAL env variable"
    exit 1
fi
CTDIR_ORIGINAL=${GC_CTDIR_ORIGINAL}
elif [ "$(echo ${KERN_VER} | cut -c1-1)" = "2" ] && \
    [ "$(echo ${KERN_VER} | cut -c1-6)" != "2.6.39" ]; then
CTDIR_ORIGINAL="REPLY"
else
    CTDIR_ORIGINAL="ORIGINAL"
fi

assert_integer(){
    case $1 in
        ''|*[!0-9]*) echo Invalid env variable for marks; exit 1;;
        *) echo 0 >/dev/null;;
    esac
}

mark_shift=0
mark_nop=0

if [ ! -z "${GC_MARK_SHIFT}" ]; then mark_shift=${GC_MARK_SHIFT}; fi
if [ ! -z "${GC_USE_NF_ACCEPT}" ]; then RETURN_TARGET=ACCEPT; else RETURN_TARGET=RETURN; fi

assert_integer "$mark_shift"

mark_block=$((0x1 << mark_shift))
mark_block_wait_client_fin=$((0x4 << mark_shift))
mark_filter=$((0x2 << mark_shift))
mark_whitelist=$((0x3 << mark_shift))
mark_whitelist_reply=$((0x6 << mark_shift))
mark_scanned_whitelist_reply=$((0x7 << mark_shift))
mark_scanned_allow=$((0x8 << mark_shift))
mark_generic_mask=$((0xf << mark_shift))
mark_filter_mask=$((0xd << mark_shift))

${IPTABLES_CMD} -N GUSTER 2> /dev/null
set -e
${IPTABLES_CMD} -F GUSTER

${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_nop}/${mark_generic_mask} -j CONNMARK --restore-mark --mask ${mark_generic_mask}
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_nop}/${mark_generic_mask} -j CONNMARK --set-mark ${mark_filter}/${mark_generic_mask}

# filter default packets
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_nop}/${mark_filter_mask} -j NFQUEUE ${QUEUE_CMD}

# filter requests for whitelist_reply packets

# handling fragmented request packets is not needed since with conntrack all packets are already reassembled
# ${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_whitelist_reply}/${mark_generic_mask} -p tcp -m conntrack --ctdir ${CTDIR_ORIGINAL} \
#    -m u32 --u32 "4&0x1FFF=0x1:0x1FFF" -j NFQUEUE ${QUEUE_CMD}

# We can use -m u32 to match packets with no payload:
#    -m u32 --u32 "0>>22&0x3C@12>>26&0x3C@0>>24&0xFF=0:255"
# However, this only works for payloads longer than 4 bytes.
# Therefore, we mix it up with -m length: IP header(20) + TCP header(20) + TCP options(??):
#
# Scan FIN/RST packets for both directions
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_whitelist_reply}/${mark_generic_mask} -p tcp --tcp-flags FIN FIN -j NFQUEUE ${QUEUE_CMD}
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_whitelist_reply}/${mark_generic_mask} -p tcp --tcp-flags RST RST -j NFQUEUE ${QUEUE_CMD}
#
# Packets with a length of 20 have no payload (since the minimum TCP header length is 20)
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_whitelist_reply}/${mark_generic_mask} -p tcp -m conntrack --ctdir ${CTDIR_ORIGINAL} -m length --length ${TCP_IP_MIN_HLEN} -j $RETURN_TARGET
#
# The TCP header is padded to a multiple of 4 bytes, therefore:
# * if the length is not a multiple of 4, the packet definitely has payload => we scan it
# * if the length is a multiple of 4, we either have zero or at least 4 bytes of payload, so we can use -m u32 to check
# The maximum length of the TCP header is 60, but we only add rules for commonly encountered values:
# * 32 bytes (SACK or TS)
# * 44 bytes (SACK and TS)
for LEN in $((TCP_IP_MIN_HLEN + 12)) $((TCP_IP_MIN_HLEN + 24)); do
    ${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_whitelist_reply}/${mark_generic_mask} -p tcp -m conntrack --ctdir ${CTDIR_ORIGINAL} \
        -m length --length ${LEN} ${U32_NO_PAYLOAD_MATCH} -j $RETURN_TARGET
done
# We might end up scanning a few nonstandard non-payload packets here
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_whitelist_reply}/${mark_generic_mask} -p tcp -m conntrack --ctdir ${CTDIR_ORIGINAL} -j NFQUEUE ${QUEUE_CMD}

# skip whitelisted packets
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_whitelist}/${mark_generic_mask} -j CONNMARK --save-mark --mask ${mark_generic_mask}
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_whitelist}/${mark_generic_mask} -j $RETURN_TARGET

# mark scanned whitelist_reply as normal whitelist_reply
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_scanned_whitelist_reply}/${mark_generic_mask} -j MARK --set-mark ${mark_whitelist_reply}/${mark_generic_mask}

# skip replies for whitelist_reply packets
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_whitelist_reply}/${mark_generic_mask} -j CONNMARK --save-mark --mask ${mark_generic_mask}
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_whitelist_reply}/${mark_generic_mask} -j $RETURN_TARGET

# post guster process
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_scanned_allow}/${mark_generic_mask} -j $RETURN_TARGET

# reject blocked packets
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_block}/${mark_generic_mask} -j CONNMARK --save-mark --mask ${mark_generic_mask}
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_block}/${mark_generic_mask} -p tcp -j REJECT --reject-with tcp-reset
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_block}/${mark_generic_mask} -j REJECT --reject-with ${ICMP_PORT_UNREACHABLE}

# reject blocked packets but send tcp-reset only on FIN packets for the original direction
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_block_wait_client_fin}/${mark_generic_mask} -p tcp -j CONNMARK --save-mark --mask ${mark_generic_mask}
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_block_wait_client_fin}/${mark_generic_mask} -p tcp ! --tcp-flags FIN FIN -m conntrack --ctdir ${CTDIR_ORIGINAL} -j DROP
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_block_wait_client_fin}/${mark_generic_mask} -p tcp -j REJECT --reject-with tcp-reset
${IPTABLES_CMD} -A GUSTER -m mark --mark ${mark_block_wait_client_fin}/${mark_generic_mask} -j REJECT --reject-with ${ICMP_PORT_UNREACHABLE}

set +e
