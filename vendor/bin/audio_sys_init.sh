#!/vendor/bin/sh

idme_device_type_id=`/vendor/bin/cat /proc/idme/device_type_id`
echo "audio_sys_init: device_type_id: $idme_device_type_id" > /dev/kmsg

#Karat(A1WZKXFLI43K86)/Mantra(A1Q6UGEXJZWJQ0)/Mantra+(AZDQ9AW1RNF81) audio system init parameter
if [ $idme_device_type_id == "A1WZKXFLI43K86" ] ||
   [ $idme_device_type_id == "A1Q6UGEXJZWJQ0" ] ||
   [ $idme_device_type_id == "AZDQ9AW1RNF81" ]; then
        /vendor/bin/setprop vendor.init.svc.bootanim "running"

else
        echo "audio_sys_init: unknown device_type_id - $idme_device_type_id" > /dev/kmsg
fi

