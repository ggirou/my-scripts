#!/bin/bash

source ${BASH_SOURCE%/*}/../utils/commons.sh

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

#CONF_PATH=transmission/settings.json
CONF_PATH=/etc/transmission-daemon/settings.json

# Read a value for a given key in the configuration file
# $1 key
# $2 value
function readJsonValue() {
  cat $CONF_PATH | sed -nr "s/.*\"$1\": *(.+), *$/\1/p"
}

# Replace a value for a given key in the configuration file
# $1 key
# $2 value
function replaceJsonValue() {
  printf "Set \"$1\"... "
  sed -r -i "s|(\"$1\":).+, *$|\1 $2, |g" $CONF_PATH && echo OK
}

# Packages installation
dpkg -s transmission > /dev/null || apt-get install transmission transmission-daemon

# Type username and password for RPC
username=`readJsonValue rpc-username | sed -r 's/"(.*)"/\1/g'`
askForNewValue "$username" "Username" username
read -s -p "Password: " password

echo
replaceJsonValue "peer-port" 51400
replaceJsonValue "download-dir" '"/mnt/ggirou-store/download/downloaded"'
replaceJsonValue "incomplete-dir" '"/mnt/ggirou-store/download/downloading"'
replaceJsonValue "incomplete-dir-enabled" true
replaceJsonValue "rpc-whitelist" '"127.0.0.1,192.168.0.*"'

replaceJsonValue "rpc-username" "\"$username\""
if [[ "$password" != "" ]]; then
	echo Replacing password...
	replaceJsonValue "rpc-password" "\"$password\""
fi

# Reload configuration
invoke-rc.d transmission-daemon reload

# Force VPN use
ALLOWED_LAN_RULE='-m owner --uid-owner debian-transmission -d 192.168.0.1/26 -j ACCEPT'
ONLY_VPN_RULE='-m owner --uid-owner debian-transmission ! -o tun0 -j REJECT'
iptables -D OUTPUT $ALLOWED_LAN_RULE
iptables -A OUTPUT $ALLOWED_LAN_RULE
iptables -D OUTPUT $ONLY_VPN_RULE
iptables -A OUTPUT $ONLY_VPN_RULE
iptables-save > /etc/iptables.up.rules
iptables -L --line-numbers | grep debian-transmission
echo -e "Remove rule command:\n  sudo iptables -D OUTPUT 1"