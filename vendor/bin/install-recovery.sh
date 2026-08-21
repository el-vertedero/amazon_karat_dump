#!/vendor/bin/sh
if ! applypatch --check EMMC:/dev/block/platform/soc/bootdevice/by-name/recovery$(getprop ro.boot.slot_suffix):41943040:f747209910e0ad2b8383bc82992d2c5ccd5339e4; then
  applypatch  \
          --patch /vendor/recovery-from-boot.p \
          --source EMMC:/dev/block/platform/soc/bootdevice/by-name/boot$(getprop ro.boot.slot_suffix):41943040:511c3943dda5beffb940e09683acedd6876262b5 \
          --target EMMC:/dev/block/platform/soc/bootdevice/by-name/recovery$(getprop ro.boot.slot_suffix):41943040:f747209910e0ad2b8383bc82992d2c5ccd5339e4 && \
      log -t recovery "Installing new recovery image: succeeded" || \
      log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
