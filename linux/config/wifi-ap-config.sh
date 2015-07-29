#!/bin/bash

# http://raspberry-at-home.com/hotspot-wifi-access-point/

[[ $UID == 0 ]] || { echo -e "Please run this script with sudo:\nsudo $0 $*"; exit 1; }

echo 'Available network interfaces:'
ifconfig  | egrep '^[^ ]+ .*'
echo

read -e -p "Access point on: " -i "wlan0" interface
read -e -p "Bridge on: " -i "eth0" bridge
read -e -p "Access point SSID: " ssid
read -s -e -p "Access point password: " password
echo

function configure_dhcp {
  wpa_psk=$(wpa_passphrase "$ssid" "$password") && wpa_psk=$(echo $wpa_psk | sed -r 's/.* psk=(.+) .*/\1/') || { echo "$wpa_psk"; exit 1; }
  sed -r "s/^interface=.*/interface=$interface/" -i /etc/hostapd/hostapd.conf
  sed -r "s/^ssid=.*/ssid=$ssid/" -i /etc/hostapd/hostapd.conf
  sed -r "s/^wpa_(passphrase|psk)=.*/wpa_psk=$wpa_psk/" -i /etc/hostapd/hostapd.conf
  service hostapd restart
  # hostapd /etc/hostapd/hostapd.conf
}

function configure_bridge {
  iptables -t nat -A POSTROUTING -o $bridge -j MASQUERADE
  iptables -A FORWARD -i $bridge -o $interface -m state --state RELATED,ESTABLISHED -j ACCEPT
  iptables -A FORWARD -i $interface -o $bridge -j ACCEPT

  iptables-save > /etc/iptables.ipv4.nat
}

configure_dhcp
configure_bridge
