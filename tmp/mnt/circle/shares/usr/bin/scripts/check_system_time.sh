#!/bin/sh

date | grep 2015 || exit 0

CIRCLE_ROOT=`cat /tmp/CIRCLE_ROOT`
date_string=`$CIRCLE_ROOT/sget -T 10 -S http://meetcircle.com 2>&1 | awk '/Date/{print;}'`
[ "x$date_string" = "x" ]  && exit 0

gmt_day=`echo $date_string | awk '{print $3;}'`
gmt_month=`echo $date_string | awk '{print $4;}'`
gmt_year=`echo $date_string | awk '{print $5;}'`
gmt_time=`echo $date_string | awk '{print $6;}'`

month=1
for i in Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ; do
	if [ "$i" = "$gmt_month" ] ; then
		gmt_month=$month
		break
	fi
	month=`expr $month + 1`
done

mytime=`printf "%4d.%02d.%02d-%s" $gmt_year $gmt_month $gmt_day $gmt_time`
date -u -s $mytime

