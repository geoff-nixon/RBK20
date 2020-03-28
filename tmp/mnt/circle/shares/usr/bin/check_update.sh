#!/bin/sh

CIRCLE_ROOT=`cat /tmp/CIRCLE_ROOT`

DIR=$CIRCLE_ROOT
export PATH=$PATH:$DIR
export LD_LIBRARY_PATH=$DIR


NEWTZ=`$DIR/get_tz`
export TZ=$NEWTZ
[ "x$NEWTZ" = "x" ] && export TZ='GMT8DST,M03.02.00,M11.01.00'

# check time window
current_hour=`date +%k`
if [ $current_hour -gt 4 -o $current_hour -lt 1 ]; then
	# not in time window 1am - 4am
	echo "0"
	exit
fi

#check last API command
if [ -s $CIRCLE_ROOT/last_api ]; then
	time_last_api=`date -r $CIRCLE_ROOT/last_api +%s`
	time_now=`date +%s`
	time_elapsed=`expr $time_now - $time_last_api`
	if [ $time_elapsed -lt 3600 ]; then
		# API command within last hour ... canceling firmware update check
		echo "0"
		exit
	fi
fi

echo "1"
