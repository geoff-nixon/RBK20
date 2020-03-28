#!/bin/sh

if [ "$#" -lt 3 ]; then
	echo "cleanup_log_files.sh <max_log_days> <max_usage_days> <max_circle_MB>"
	exit 0
fi

CIRCLE_ROOT=`cat /tmp/CIRCLE_ROOT`

echo "checking for old log files ..."
if [ "$1" -gt "0" ]; then
	max_log_time=$(($1 * 24 * 60 * 60))
	files=`ls -1 $CIRCLE_ROOT/tracking/*.log $CIRCLE_ROOT/tracking/*.dnslog $CIRCLE_ROOT/tracking/*.blocked`
	for i in $files ; do
		file_time=$(($(date +%s) - $(date +%s -r $i)))
		if [ "$file_time" -gt "$max_log_time" ]; then
			echo $i
			rm -f $i
		fi
	done
fi

echo "checking for old usage files ..."
if [ "$2" -gt "0" ]; then
	max_usage_time=$(($2 * 24 * 60 * 60))
	files=`ls -1 $CIRCLE_ROOT/tracking/*.usage`
	for i in $files ; do
		file_time=$(($(date +%s) - $(date +%s -r $i)))
		if [ "$file_time" -gt "$max_usage_time" ]; then
			echo $i
			rm -f $i
		fi
	done
fi

preload_usage_KB=0
if [ -s /tmp/CIRCLE_PRELOAD ]; then
	CIRCLE_PRELOAD=`cat /tmp/CIRCLE_PRELOAD`
	preload_usage_KB=`du -s $CIRCLE_PRELOAD	| awk '{print $1;}'`
fi

usage_KB=$(($preload_usage_KB+`du -s $CIRCLE_ROOT | awk '{print $1;}'`))
echo "checking overall Circle data usage ..."
echo "usage (KB): $usage_KB"
echo "limit (KB): $(($3*1024))"
if [ "$usage_KB" -ge "$(($3*1024))" ]; then
	target_usage=$((($3-2)*1024))
	files=`ls -1tr $CIRCLE_ROOT/tracking/*.log $CIRCLE_ROOT/tracking/*.blocked $CIRCLE_ROOT/tracking/*.dnslog`
	echo "data limits reached: purging log files ..."
	echo "target (KB): $target_usage"
	for i in $files; do
		echo $i
		rm -f $i
		usage_KB=$(($preload_usage_KB+`du -s $CIRCLE_ROOT | awk '{print $1;}'`))
		if [ "$usage_KB" -le "$target_usage" ]; then
			break
		fi
	done

	if [ "$usage_KB" -gt "$target_usage" ]; then
		files=`ls -1tr $CIRCLE_ROOT/api_log.*`
		echo "purging API log files ..."
		for i in $files; do
			echo $i
			rm -f $i
			usage_KB=$(($preload_usage_KB+`du -s $CIRCLE_ROOT | awk '{print $1;}'`))
			if [ "$usage_KB" -le "$target_usage" ]; then
				break
			fi
		done
	fi

	if [ "$usage_KB" -gt "$target_usage" ]; then
		files=`ls -1tr $CIRCLE_ROOT/tracking/*.usage`
		echo "purging usage files ..."
		for i in $files; do
			echo $i
			rm -f $i
			usage_KB=$(($preload_usage_KB+`du -s $CIRCLE_ROOT | awk '{print $1;}'`))
			if [ "$usage_KB" -le "$target_usage" ]; then
				break
			fi
		done
	fi
fi

exit 0

