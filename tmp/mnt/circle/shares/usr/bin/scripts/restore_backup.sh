#!/bin/sh
if [ $# != 3 ] ; then
	echo "restore_backup.sh <filename> <password> <max profiles>"
	exit 1
fi

CIRCLE_ROOT=`cat /tmp/CIRCLE_ROOT`
CIRCLE_BASE=`cat /tmp/CIRCLE_BASE`

#clear out any existing old backup files
rm -rf $CIRCLE_ROOT/backup.tgz $CIRCLE_ROOT/backup/

/tmp/aescrypt -d -p $2 -o $CIRCLE_ROOT/backup.tgz $1

if [ ! -s $CIRCLE_ROOT/backup.tgz ] ; then
	echo "failed to decrypt backup"
	exit 1
fi

mkdir -p $CIRCLE_ROOT/backup
tar -C $CIRCLE_ROOT/backup/ -xzf $CIRCLE_ROOT/backup.tgz configure.xml photos backup.version
if [ ! -f $CIRCLE_ROOT/backup/configure.xml -o ! -f $CIRCLE_ROOT/backup/backup.version -o ! -d $CIRCLE_ROOT/backup/photos ] ; then
	echo "missing files in backup"
	rm -rf $CIRCLE_ROOT/backup.tgz $CIRCLE_ROOT/backup/
	exit 1
fi
for i in $CIRCLE_ROOT/backup/photos/* ; do
	if [ ! -f $i -o -h $i ] ; then
		echo "invalid files in photos"
		rm -rf $CIRCLE_ROOT/backup.tgz $CIRCLE_ROOT/backup/
		exit 1
	fi
done

check_failed=0
#check to make sure current version >= backup version
if [ -s $CIRCLE_ROOT/backup/backup.version ] ; then
	v_current=`cat $CIRCLE_BASE/VERSION | cut -f 1 -d -`
	v_backup=`cat $CIRCLE_ROOT/backup/backup.version | cut -f 1 -d -`
	if [ "$v_current" \< "$v_backup" ] ; then
		echo "restore failed: current version less than backup version"
		check_failed=2
	fi
fi

#check to make sure number of profiles <= max number of profiles
num_profiles=`grep -o "<user pid=" $CIRCLE_ROOT/backup/configure.xml | wc -l`
if [ $num_profiles -gt $3 ] ; then
	echo "restore failed: too many profiles in backup"
	check_failed=3
fi

#simple checks on configure.xml
grep -q "<config>" $CIRCLE_ROOT/backup/configure.xml  || check_failed=1
grep -q "<wifi>" $CIRCLE_ROOT/backup/configure.xml  || check_failed=1
grep -q "<overall>" $CIRCLE_ROOT/backup/configure.xml  || check_failed=1
grep -q "<users>" $CIRCLE_ROOT/backup/configure.xml  || check_failed=1
grep -q "<devices>" $CIRCLE_ROOT/backup/configure.xml  || check_failed=1
grep -q "<contact>" $CIRCLE_ROOT/backup/configure.xml  || check_failed=1

if [ $check_failed -gt 0 ] ; then
	echo "bad configuration file"
	rm -rf $CIRCLE_ROOT/backup.tgz $CIRCLE_ROOT/backup/
	exit $check_failed
fi

#replace configure.xml and photos/ with backups
cp -f $CIRCLE_ROOT/backup/configure.xml $CIRCLE_ROOT/configure.xml
rm -rf $CIRCLE_ROOT/photos/
cp -rf $CIRCLE_ROOT/backup/photos/ $CIRCLE_ROOT/photos/
rm -rf $CIRCLE_ROOT/backup.tgz $CIRCLE_ROOT/backup/

#clear out old tracking files and re-add go directory
rm -rf $CIRCLE_ROOT/tracking/*
mkdir $CIRCLE_ROOT/tracking/go

echo "configuration restored from backup"
exit 0
