#!/system/bin/sh
#
# Copyright (c) 2019 - 2026 Amazon.com, Inc. or its affiliates.  All rights reserved.
# PROPRIETARY/CONFIDENTIAL.  USE IS SUBJECT TO LICENSE TERMS.
#

# Get the eMMC block device node
# At this time, we're assuming that there's only one eMMC device.
# In the case that there are multiple, we'll just report lifetime metrics on
# the first one.
# Tablet devices may have SD cards attached, which will also be a sysfs block
# device node. Make sure to choose the eMMC device node. The scr node only
# exists for SD cards.
for i in 0 1 2 3 4
do
  if [ -e "/sys/block/mmcblk$i" ] && [ ! -e "/sys/block/mmcblk$i/device/scr" ]; then
    emmc_device="mmcblk$i"
    break
  fi
done

# Exit with error if no valid sysfs eMMC node is found
if [ "$emmc_device" = "" ]; then
  echo "read_lifetime.sh failed, no valid sysfs eMMC node"
  exit 1
fi

lifetime_file_name="/sys/block/$emmc_device/device/life_time";
pre_eol_info_file_name="/sys/block/$emmc_device/device/pre_eol_info";
manfid_file_name="/sys/block/$emmc_device/device/manfid";

lifetime=$(<$lifetime_file_name)
pre_eol_info=$(<$pre_eol_info_file_name)
manfid=$(<$manfid_file_name)

lifetime="${lifetime} ${pre_eol_info} ${manfid}"
setprop sys.amzn_bsp_diag.emmc_lifetime "$lifetime"

# Read additional device information for detailed WTF logging
name_file_name="/sys/block/$emmc_device/device/name";
fwrev_file_name="/sys/block/$emmc_device/device/fwrev";
hwrev_file_name="/sys/block/$emmc_device/device/hwrev";

# Read device name, firmware revision, and hardware revision
if [ -e "$name_file_name" ]; then
  device_name=$(<$name_file_name)
else
  device_name="Unknown"
fi

if [ -e "$fwrev_file_name" ]; then
  fwrev=$(<$fwrev_file_name)
else
  fwrev="0x0"
fi

if [ -e "$hwrev_file_name" ]; then
  hwrev=$(<$hwrev_file_name)
else
  hwrev="0x0"
fi

# Set device info property: "name fwrev hwrev"
device_info="${device_name} ${fwrev} ${hwrev}"
setprop sys.amzn_bsp_diag.emmc_device_info "$device_info"
