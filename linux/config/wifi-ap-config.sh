#!/bin/bash

# http://raspberry-at-home.com/hotspot-wifi-access-point/

[[ $UID == 0 ]] || { echo -e "Please run this script with sudo:\nsudo $0 $*"; exit 1; }

echo 'Available network interfaces:'
ifconfig  | egrep '^[^ ]+ .*'
echo

read -e -p "Access point on: " -i "wlan0" interface
read -e -p "Bridge on: " -i "eth0" bridge
read -e -p "Router static IP: " -i "192.168.1.254" router_ip
echo

function configure_hostapd {
  read -e -p "Access point SSID: " ssid
  read -s -e -p "Access point password: " password

  wpa_psk=$(wpa_passphrase "$ssid" "$password") && wpa_psk=$(echo $wpa_psk | sed -r 's/.* psk=(.+) .*/\1/') || { echo "$wpa_psk"; exit 1; }
  sed -r "s/^interface=.*/interface=$interface/" -i /etc/hostapd/hostapd.conf
  sed -r "s/^ssid=.*/ssid=$ssid/" -i /etc/hostapd/hostapd.conf
  sed -r "s/^wpa_(passphrase|psk)=.*/wpa_psk=$wpa_psk/" -i /etc/hostapd/hostapd.conf

  sed -r 's|^#?DAEMON_CONF=.*|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' -i /etc/default/hostapd
}

function configure_dhcp {
  sed -r 's/^#DHCPD/DHCPD/' -i /etc/default/isc-dhcp-server
  sed -r "s/^INTERFACES=\".*\"/INTERFACES=\"$interface\"/" -i /etc/default/isc-dhcp-server
  
  sed "/^# --++--/,/^# ++--++/d" -i /etc/dhcp/dhcpd.conf
  cat >> /etc/dhcp/dhcpd.conf <<EOF
# --++-- $interface
subnet 192.168.1.0 netmask 255.255.255.0 {
  range 192.168.1.1 192.168.1.25;
  option domain-name-servers 8.8.4.4;
  option routers $router_ip;
}
# ++--++ $interface
EOF
}

function configure_network_interfaces {
  # delete lines from previous interface configuration
  sed "/$interface/,/^$/d" -i /etc/network/interfaces

  cat >> /etc/network/interfaces <<EOF
auto $interface
allow-hotplug $interface
iface $interface inet static
  address $router_ip
  netmask 255.255.255.0
up iptables-restore < /etc/iptables.ipv4.nat

EOF

  sed s/^#net.ipv4.ip_forward/net.ipv4.ip_forward/ -i /etc/sysctl.conf
  
  touch /etc/iptables.ipv4.nat
}

function configure_bridge {
  # Remove previous rules
  iptables-save | grep '\-A FORWARD' | sed 's/-A/-D/' | xargs -L1 iptables
  iptables-save | grep '\-A POSTROUTING' | sed 's/-A/-t nat -D/' | xargs -L1 iptables
  
  iptables -t nat -A POSTROUTING -o $bridge -j MASQUERADE
  iptables -A FORWARD -i $bridge -o $interface -m state --state RELATED,ESTABLISHED -j ACCEPT
  iptables -A FORWARD -i $interface -o $bridge -j ACCEPT

  iptables-save > /etc/iptables.ipv4.nat
}

function restart_services {
  service dhcpcd restart

  service hostapd restart
  # hostapd /etc/hostapd/hostapd.conf

  tail -f /var/log/syslog
}

configure_hostapd
configure_bridge
configure_network_interfaces
configure_dhcp
restart_services
