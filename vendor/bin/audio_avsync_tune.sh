#!/vendor/bin/sh

idme_device_type_id=`/vendor/bin/cat /proc/idme/device_type_id`
echo "audio_avsync_tune: device_type_id: $idme_device_type_id" > /dev/kmsg

#Karat(A1WZKXFLI43K86)/Mantra(A1Q6UGEXJZWJQ0)/Mantra+(AZDQ9AW1RNF81) audio avsync tuning parameter
if [ $idme_device_type_id == "A1WZKXFLI43K86" ] ||
   [ $idme_device_type_id == "A1Q6UGEXJZWJQ0" ] ||
   [ $idme_device_type_id == "AZDQ9AW1RNF81" ]; then
        #default hdmi out audio settings
        /vendor/bin/setprop persist.vendor.audio.hal.hdmi.format -1

        #Add HDMI/AVLS avsync tuning values, defaults defined here

        # tunnel mode audio pts adjust
        /vendor/bin/setprop vendor.tunnelmode.raw.apts.adjust 0
        /vendor/bin/setprop vendor.tunnelmode.pcm.apts.adjust -70

        # Audio pts adjust for AV sync fine tuning in non tunnel mode in MS12
        /vendor/bin/setprop vendor.apts_tune.non_tunnel_pcm 0
        /vendor/bin/setprop vendor.apts_tune.non_tunnel_dlb 0

        # A2DP tunnel mode avsync tune
        /vendor/bin/setprop vendor.tunnelmode.bt.apts.adjust 150
else
        echo "audio_avsync_tune: unknown device_type_id - $idme_device_type_id" > /dev/kmsg
fi
