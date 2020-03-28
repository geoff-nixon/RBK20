#!/bin/sh

DIR="/opt/bitdefender"
ETC_DIR="$DIR/etc"
GDIR="$DIR/guster/latest"
NANNY_BIN="$GDIR/nanny"
GUSTER_BIN="$GDIR/guster"
GUSTER_LOG_DIR="$DIR/var/tmp/guster"

ulimit -s 128

cd $GDIR
sh scripts/create_chain.sh 0

killall nanny
killall guster

while [ "$(pidof guster)" != "" ]; do
    sleep 1
done

$NANNY_BIN --gbin $GUSTER_BIN -c $GDIR/nanny.yaml >$GUSTER_LOG_DIR/nanny.out.log 2>&1 &
$GUSTER_BIN -q 0 -c $GDIR/guster.yaml -c $ETC_DIR/guster.yaml >$GUSTER_LOG_DIR/guster.out.log 2>&1 &

while [ "$(pidof guster)" == "" ]; do
    sleep 1
done
