#!/bin/sh
#make sure to readd the sleep if it is taken out of factory_default.sh
#sleep 3 
CIRCLE_ROOT=`cat /tmp/CIRCLE_ROOT`
$CIRCLE_ROOT/scripts/circle/factory_default.sh

