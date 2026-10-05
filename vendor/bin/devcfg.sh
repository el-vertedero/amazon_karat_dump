#!/vendor/bin/sh

idme_device_type_id=`/vendor/bin/cat /proc/idme/device_type_id`
echo "devcfg: device_type_id: $idme_device_type_id" > /dev/kmsg

#Karat(A1WZKXFLI43K86)/Mantra(A1Q6UGEXJZWJQ0)/Mantra+(AZDQ9AW1RNF81) Netflix
if [ $idme_device_type_id == "A1WZKXFLI43K86" ] ||
   [ $idme_device_type_id == "A1Q6UGEXJZWJQ0" ] ||
   [ $idme_device_type_id == "AZDQ9AW1RNF81" ]; then
        /vendor/bin/setprop ro.vendor.nrdp.modelgroup FIRETVSTICK2023
        /vendor/bin/setprop ro.vendor.nrdp.validation ninja_9
        /vendor/bin/setprop ro.vendor.nrdp.audio.mixer.buffersize 1024
#Kara(A3EVMLQTU6WL1W)
elif [ $idme_device_type_id == "A3EVMLQTU6WL1W" ]; then
        /vendor/bin/setprop ro.vendor.nrdp.modelgroup FIRETVSTICK2021
        /vendor/bin/setprop ro.vendor.nrdp.validation ninja_8
        /vendor/bin/setprop ro.vendor.nrdp.audio.mixer.buffersize 1024
else
        echo "devcfg: unknown device_type_id - $idme_device_type_id" > /dev/kmsg
fi

