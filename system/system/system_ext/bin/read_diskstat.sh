#!/system/bin/sh
#
# Copyright (c) 2022 Amazon.com, Inc. or its affiliates.  All rights reserved.
#
# PROPRIETARY/CONFIDENTIAL. USE IS SUBJECT TO LICENSE TERMS.

MMC0_DISK_STATS_PATH="/sys/block/mmcblk0/stat"
MMC1_DISK_STATS_PATH="/sys/block/mmcblk1/stat"
DISK_WRITE_PROP="sys.amzn_bsp_diag.disk_write"

if test -f $MMC0_DISK_STATS_PATH; then
    MMC_PATH=$MMC0_DISK_STATS_PATH
elif test -f $MMC1_DISK_STATS_PATH; then
    MMC_PATH=$MMC1_DISK_STATS_PATH
else
    exit
fi

# Read previous disk written and uptime
write_prop=$(getprop "$DISK_WRITE_PROP")
len=`expr $(echo $write_prop | awk '{ print length }')`
if [ $len -gt 5 ]; then
    echo "write_prop $write_prop"
    prev_diskwrite=`expr $(echo $write_prop | awk '{print $1}')`
    prev_diskwrite_time=`expr $(echo $write_prop | awk '{print $2}')`
fi

# Read current disk written and uptime
total_diskwrite=`expr $(cat $MMC_PATH | awk '{print $7}')`
total_diskwrite=`expr $total_diskwrite / 2`  # Convert as KiB
diskwrite_time=$(cat /proc/uptime | awk '{print $1}')
diskwrite_time=`expr $(printf "%.0f" $diskwrite_time)`

# Get disk write rate [KiB/H] when conditions are met
if [ ! -z "$prev_diskwrite" ] && [ ! -z "$total_diskwrite" ] && [ $total_diskwrite -gt $prev_diskwrite ] &&
   [ ! -z "$prev_diskwrite_time" ] && [ ! -z "$diskwrite_time" ] && [ $diskwrite_time -gt $prev_diskwrite_time ]
then
    diskwritten=`expr $total_diskwrite - $prev_diskwrite`
    diskwritten=`expr $diskwritten \* 3600` # KiB written * 3600 sec
    duration=`expr $diskwrite_time - $prev_diskwrite_time`
    rate=`expr $diskwritten / $duration`   # KiB / hour
else
    echo "previous diskwrite $prev_diskwrite, current diskwrite $total_diskwrite"
    echo "previous diskwrite time $prev_diskwrite_time, current diskwrite time $diskwrite_time"
fi
setprop "$DISK_WRITE_PROP" "$total_diskwrite $diskwrite_time $rate" # total written, duration
