source ${BASH_SOURCE%/*}/../utils/commons.sh

# Set hostname
currentHostname=`cat /etc/hostname`
askForNewValue "$currentHostname" "Set hostname" newHostname

sudo sh -c "echo \"$newHostname\" > /etc/hostname"
sudo sed -i "s/$currentHostname/$newHostname/g" /etc/hosts

# Windows Network compatibility
# Samba and winbind are already installed in XBMC
# sudo apt-get -y install samba winbind
# Add wins to the hosts line to resolve network names
sudo sed -ri 's/^hosts:(.+)return\]( wins)*/hosts:\1return] wins/g' /etc/nsswitch.conf

# Default keyboard layout to fr
sudo sed -ri "s/XKBLAYOUT=\".+\"/XKBLAYOUT=\"fr\"/g" /etc/default/keyboard
