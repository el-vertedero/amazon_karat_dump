#!/vendor/bin/sh
if ! applypatch --check EMMC:/dev/block/platform/soc/bootdevice/by-name/recovery$(getprop ro.boot.slot_suffix):41943040:3db42e3ac7c170495f0fadb1089c66217fba84bd; then
  applypatch  \
          --patch /vendor/recovery-from-boot.p \
          --source EMMC:/dev/block/platform/soc/bootdevice/by-name/boot$(getprop ro.boot.slot_suffix):41943040:f8a5d1c292b39560f166a447e645e0e7a4ddb459 \
          --target EMMC:/dev/block/platform/soc/bootdevice/by-name/recovery$(getprop ro.boot.slot_suffix):41943040:3db42e3ac7c170495f0fadb1089c66217fba84bd && \
      log -t recovery "Installing new recovery image: succeeded" || \
      log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
