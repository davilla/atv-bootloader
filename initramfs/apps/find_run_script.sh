#!/bin/bash
#
# find_run_script
# search for named script on root level of all partitions
# execute the first one you find.
#
#
SCRIPT=$1
#
# ROOT is where the rootfs partition is mounted
ROOT=/mnt/rootfs
if [ ! -d "$ROOT" ]; then
	mkdir $ROOT
fi

# sda is typically the appletv internal hard drive (there can be only one)
# sdb is typically a USB disk device (pen or HD)
#SEARCH1="`ls /dev/sd* | grep sd[b-h][1-9]`"
#SEARCH2=" `ls /dev/sda* | grep sd[a][1-9]`"
SEARCH1="`grep sd[b-h][1-9] /proc/partitions | awk '{print $4}'`"
SEARCH2=" `grep sd[a][1-9] /proc/partitions | awk '{print $4}'`"

SEARCH_PARTITIONS="$SEARCH1""$SEARCH2"
#echo "$SEARCH_PARTITIONS"

# search for boot configs
for x in $SEARCH_PARTITIONS; do
	if `mount -o rw,force,noatime /dev/${x} $ROOT > /dev/null 2>&1`; then
                if [ -f "$ROOT/$SCRIPT" ]; then
                        echo "${x}/$SCRIPT found"
			chmod +x $ROOT/$SCRIPT
			$ROOT/$SCRIPT
			umount $ROOT
			exit 0
		fi
		#
		umount $ROOT
	fi
done

exit 1
