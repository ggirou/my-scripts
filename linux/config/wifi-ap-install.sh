#!/bin/bash

# http://raspberry-at-home.com/hotspot-wifi-access-point/

[[ $UID == 0 ]] || { echo -e "Please run this script with sudo:\nsudo $0 $*"; exit 1; }

echo 'Available network interfaces:'
ifconfig  | egrep '^[^ ]+ .*'
echo

read -e -p "Network interface to use: " -i "wlan0" interface
echo

function install_hostapd_dhcp {
  sudo apt-get install -y hostapd isc-dhcp-server
  echo

  echo 'Backuping files...'
  cp -n /etc/network/interfaces /etc/network/interfaces.bak

  cp -n /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak

  if [ ! -f /etc/hostapd/hostapd.conf ]; then
    zcat /usr/share/doc/hostapd/examples/hostapd.conf.gz > /etc/hostapd/hostapd.conf
  fi
  
  cp -n /etc/default/hostapd /etc/default/hostapd.bak
  cp -n /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.bak

  echo
}

function install_rtl8188c_hostapd {

  echo 'Downloading drivers for Realtek Semiconductor Corp. RTL8188CUS 802.11n WLAN Adapter...'
  wget http://12244.wpc.azureedge.net/8012244/drivers/rtdrivers/cn/wlan/0001-RTL8188C_8192C_USB_linux_v4.0.2_9000.20130911.zip -O /tmp/RTL8188C.zip

  zipinfo -1 /tmp/RTL8188C.zip *.tar.gz | grep /wpa_supplicant_hostapd- | xargs unzip -p RTL8188C.zip | tar xz -C /tmp
  zipinfo -1 /tmp/RTL8188C.zip | grep rtl_hostapd_2G.conf | xargs unzip -p /tmp/RTL8188C.zip > /etc/hostapd/hostapd.conf

  pushd /tmp/wpa_supplicant_hostapd-*/hostapd
  echo 'Compiling hostapd for RTL8188CUS...'
  make
  echo 'Installing hostapd for RTL8188CUS...'
  make install
  popd
  echo
}

function configure_dhcp {
  sed -r 's/^#DHCPD/DHCPD/' -i /etc/default/isc-dhcp-server
  sed -r "s/^INTERFACES=\".*\"/INTERFACES=\"$interface\"/" -i /etc/default/isc-dhcp-server
  
  sed '/wlan0/,/^}$/d' -i /etc/dhcp/dhcpd.conf
  cat >> /etc/dhcp/dhcpd.conf <<EOF
subnet 192.168.1.0 netmask 255.255.255.0 { # $interface
  range 192.168.1.1 192.168.1.9;
  option domain-name-servers 8.8.4.4;
  option routers  192.168.1.254;
}
EOF
}

function configure_hostapd {
   sed -r 's|^#?DAEMON_CONF=.*|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' -i /etc/default/hostapd
}

function configure_network_interfaces {
  # delete lines from previous interface configuration
  sed "/$interface/,/^$/d" -i /etc/network/interfaces
  cat >> /etc/network/interfaces <<EOF
auto wlan0
allow-hotplug wlan0
iface wlan0 inet static
        address 192.168.1.254
        netmask 255.255.255.0
up iptables-restore < /etc/iptables.ipv4.nat

EOF

  sed s/^#net.ipv4.ip_forward/net.ipv4.ip_forward/ -i /etc/sysctl.conf
  
  touch /etc/iptables.ipv4.nat
}

install_hostapd_dhcp
install_rtl8188c_hostapd
configure_dhcp
configure_hostapd
configure_network_interfaces
