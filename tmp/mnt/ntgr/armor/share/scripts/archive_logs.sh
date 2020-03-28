#!/bin/sh

ROOTDIR=/tmp/bitdefender_logs
mkdir -p ${ROOTDIR}
PATCH_INFO=${ROOTDIR}/PATCH_INFO
mkdir -p ${PATCH_INFO}

STORAGEDATA=/opt/bitdefender/etc/storage.data
ETC_LOGGING=/opt/bitdefender/etc/logging
DAEMONSLOGS_PERSISTENT=/opt/bitdefender/var/log
DAEMONSLOGS_TMP=/tmp/bdlogs/opt/bitdefender/var/log
GUSTERLOGS1=/opt/bitdefender/var/tmp/guster/log
GUSTERLOGS2=/opt/bitdefender/var/tmp/guster/events*log
GUSTERLOGS3=/opt/bitdefender/var/tmp/guster/gusterupd*log

# Other miscellaneous info.
cp /opt/bitdefender/bitdefender-release                ${ROOTDIR}
ps -w                                           > ${ROOTDIR}/ps
dmesg                                           > ${ROOTDIR}/dmesg
iptables -nvL -t filter                         > ${ROOTDIR}/iptables-filter
LD_LIBRARY_PATH=/opt/bitdefender/lib /opt/bitdefender/bin/gtables -l -t detection > ${ROOTDIR}/gtables.detection
LD_LIBRARY_PATH=/opt/bitdefender/lib /opt/bitdefender/bin/gtables -l -t traffic   > ${ROOTDIR}/gtables.traffic
top -b -n 1                                     > ${ROOTDIR}/top
uptime                                          > ${ROOTDIR}/uptime
date -R                                         > ${ROOTDIR}/date

#Patch info
cp /opt/bitdefender/patches/latest/patch.info ${PATCH_INFO}
cp /opt/bitdefender/etc/patch.server ${PATCH_INFO}
cp /opt/bitdefender/var/update/patch.csum ${PATCH_INFO}

# Create the archive.
ARNAME=bitdefender_logs.tar.gz

tar -czf /tmp/${ARNAME} -C ${ROOTDIR} . ${STORAGEDATA} ${ETC_LOGGING} ${DAEMONSLOGS_PERSISTENT} ${DAEMONSLOGS_TMP} ${GUSTERLOGS1} ${GUSTERLOGS2} ${GUSTERLOGS3}
rm -rf ${ROOTDIR}

# Encrypt the archive.
PUBKEY=/opt/bitdefender/etc/logs-pub.pem
ENCSYMKEY=bitdefender_key.enc
TEMPKEY=/tmp/bitdefender-sym-key-temp

LD_LIBRARY_PATH=/opt/bitdefender/lib /opt/bitdefender/bin/bdcrypto gen-sym-key -k ${TEMPKEY}
LD_LIBRARY_PATH=/opt/bitdefender/lib /opt/bitdefender/bin/bdcrypto aes-encrypt -k ${TEMPKEY} -i /tmp/${ARNAME} -o /tmp/${ARNAME}.enc
LD_LIBRARY_PATH=/opt/bitdefender/lib /opt/bitdefender/bin/bdcrypto rsa-encrypt -k ${PUBKEY} -i ${TEMPKEY} -o /tmp/${ENCSYMKEY}

tar -czf /tmp/${ARNAME} -C /tmp ${ENCSYMKEY} ${ARNAME}.enc
rm -f /tmp/${ENCSYMKEY} /tmp/${ARNAME}.enc ${TEMPKEY}

