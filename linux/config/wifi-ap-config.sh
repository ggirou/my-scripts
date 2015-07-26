#!/bin/bash

# http://raspberry-at-home.com/hotspot-wifi-access-point/

if [[ $UID != 0 ]]; then echo -e "Please run this script with sudo:\nsudo $0 $*"; exit 1; fi

# TODO update /etc/hostapd/hostapd.conf
# interface
# ssid
# wpa_passphrase


# TODO bridge configuration
#iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
#iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

#iptables-save > /etc/iptables.ipv4.nat
