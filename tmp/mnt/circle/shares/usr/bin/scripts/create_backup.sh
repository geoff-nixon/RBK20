#!/bin/sh
if [ $# != 2 ] ; then
	echo "create_backup.sh <filename> <password>"
	exit 1
fi

CIRCLE_ROOT=`cat /tmp/CIRCLE_ROOT`
CIRCLE_BASE=`cat /tmp/CIRCLE_BASE`

#clear out old backup file, if exists
rm -f $CIRCLE_ROOT/backup.tgz

cp $CIRCLE_BASE/VERSION $CIRCLE_ROOT/backup.version
tar -C $CIRCLE_ROOT -czf $CIRCLE_ROOT/backup.tgz configure.xml photos/ backup.version
rm -f $CIRCLE_ROOT/backup.version

if [ ! -s $CIRCLE_ROOT/backup.tgz ] ; then
	echo "failed to create backup"
	exit 1
fi

/tmp/aescrypt -e -p $2 -o $1 $CIRCLE_ROOT/backup.tgz
rm -f $CIRCLE_ROOT/backup.tgz

if [ ! -s $1 ] ; then
	echo "failed to encrypt backup"
	exit 1
fi

exit 0
