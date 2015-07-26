#!/bin/bash

# https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md

if [[ $UID != 0 ]]; then echo -e "Please run this script with sudo:\nsudo $0 $*"; exit 1; fi

echo 'Available network interfaces:'
ifconfig  | egrep '^[^ ]+ .*'
echo

read -e -p "Network interface to use: " -i "wlan0" interface
echo

echo 'Available SSID:'
iwlist $interface scan | egrep 'ESSID:|IE:'

read -p "SSID: " ssid
read -p "Password: " -s password; echo
echo

cp -n /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.bak
out=$(wpa_passphrase "$ssid" "$password") && echo "$out" | grep -v '#psk' >> /etc/wpa_supplicant/wpa_supplicant.conf || echo "$out" && exit 1
wpa_supplicant -B -D wext -i $interface -c /etc/wpa_supplicant/wpa_supplicant.conf
ifdown $interface
ifup $interface
