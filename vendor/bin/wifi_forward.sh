#!/vendor/bin/sh
#
# Copyright (c) 2024 Amazon.com, Inc. or its affiliates.  All rights reserved.
# PROPRIETARY/CONFIDENTIAL.  USE IS SUBJECT TO LICENSE TERMS.
#

# Setup forwarding with ip and iptables for softAP.
#
# iptables controls
#
#  * start       - setup forwarding for softap
#  * stop        - stops all forwarding
#
#

ECHO=/vendor/bin/echo
IPTABLES=/system/bin/iptables-wrapper-1.0
IP6TABLES=/system/bin/ip6tables-wrapper-1.0
IP=/system/bin/ip-wrapper-1.0
IWPRIV=/vendor/bin/iwpriv

# Main functionality needing timing and log capture
#  usage: main $@
main()
{

# Capture timing of this script
time {

# Status
STATUS=""
RESULT=0

# Default values
WLAN_INTERFACE='wlan0'

wifi_multicast_start_stop()
{
    if [[ "$1" == "start" ]]; then
        # Enable Multicast in Wifi firmware
        $IWPRIV $WLAN_INTERFACE driver "set_mcastburst 1" > /dev/null
        # Set Multicast rate to MCS2
        $IWPRIV $WLAN_INTERFACE driver "fixedmrate=0-2-0-2-0-0-0-0-0-0" > /dev/null
    else #stop
        # Disable Multicast in Wifi firmware
        $IWPRIV $WLAN_INTERFACE driver "set_mcastburst 0" > /dev/null
        # Set Multicast rate to Auto
        $IWPRIV $WLAN_INTERFACE driver "fixedmrate=auto" > /dev/null
    fi
}

# Process command
#  usage: process_cmd $@
process_cmd()
{
    case "$1" in
        start)
            # Enable forwarding
            $ECHO '1' > /proc/sys/net/ipv4/conf/all/forwarding
            $IPTABLES -I FORWARD -j ACCEPT
            $ECHO '1' > /proc/sys/net/ipv6/conf/all/forwarding
            $IP6TABLES -I FORWARD -j ACCEPT
            # disable unicast DHCP forwarding
            $IPTABLES -I FORWARD -p udp --sport 67 -j DROP
            $IPTABLES -I FORWARD -p udp --sport 68 -j DROP
            # add ip rule
            $IP rule add from all fwmark 0x0/0xffff lookup $2 prio 20000
            wifi_multicast_start_stop "start"
            ;;

        stop)
            $IP6TABLES -D FORWARD -j ACCEPT
            $ECHO '0' > /proc/sys/net/ipv6/conf/all/forwarding
            $IPTABLES -D FORWARD -j ACCEPT
            $ECHO '0' > /proc/sys/net/ipv4/conf/all/forwarding
            # remove disabling unicast DHCP forwarding
            $IPTABLES -D FORWARD -p udp --sport 67 -j DROP
            $IPTABLES -D FORWARD -p udp --sport 68 -j DROP
            wifi_multicast_start_stop "stop"
            ;;
    esac
} # process_cmd

process_cmd "$@"

} # time

exit $RESULT

} # main

main "$@"
