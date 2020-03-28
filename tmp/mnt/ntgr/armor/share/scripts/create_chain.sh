#!/bin/sh

LD_LIBRARY_PATH=/opt/bitdefender/lib /opt/bitdefender/bin/bdsett -get-key /daemons/bdcloudd/device_id > /opt/bitdefender/etc/guster/.deviceid 2>/dev/null
GC_MARK_SHIFT=20 sh /opt/bitdefender/guster/scripts/create_chain.sh $@
