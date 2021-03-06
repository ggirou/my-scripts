#!/bin/bash

# http://raspberry-at-home.com/hotspot-wifi-access-point/

[[ $UID == 0 ]] || { echo -e "Please run this script with sudo:\nsudo $0 $*"; exit 1; }

function free_space {
  # GUI-related packages
  pkgs="
  xserver-xorg-video-fbdev
  xserver-xorg xinit
  gstreamer1.0-x gstreamer1.0-omx gstreamer1.0-plugins-base
  gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-alsa
  gstreamer1.0-libav
  epiphany-browser
  lxde lxtask menu-xdg gksu
  xserver-xorg-video-fbturbo
  xpdf gtk2-engines alsa-utils
  netsurf-gtk zenity
  desktop-base lxpolkit
  weston
  omxplayer
  raspberrypi-artwork
  lightdm gnome-themes-standard-data gnome-icon-theme
  qt50-snapshot qt50-quick-particle-examples
  "

  # Edu-related packages
  pkgs="$pkgs
  idle python3-pygame python-pygame python-tk
  idle3 python3-tk
  python3-rpi.gpio
  python-serial python3-serial
  python-picamera python3-picamera
  debian-reference-en dillo x2x
  scratch nuscratch
  raspberrypi-ui-mods
  timidity
  smartsim penguinspuzzle
  pistore
  sonic-pi
  python3-numpy
  python3-pifacecommon python3-pifacedigitalio python3-pifacedigital-scratch-handler python-pifacecommon python-pifacedigitalio
  oracle-java8-jdk
  minecraft-pi python-minecraftpi
  wolfram-engine
  "

	apt-get -y remove --purge $pkgs
  apt-get -y autoremove
  apt-get -y clean
  apt-get -y autoclean
}

function install_raspberry_headers {
  # Firmware 3.18.16
  # rpi-update 33a6707cf1c96b8a2b5dac2ac9dead590db9fcaa
  rpi-update
  # reboot 

  modprobe configs

  # Install gcc 4.8.3+
  sed s/wheezy/jessie/ -i /etc/apt/sources.list
  apt-get update
  #apt-get dist-upgrade

  apt-get install gcc-4.8 g++-4.8 libncurses5-dev
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 40 --slave /usr/bin/g++ g++ /usr/bin/g++-4.8
  update-alternatives --set gcc /usr/bin/gcc-4.8

  # Ensure that date is up-to-date
  date -s "$(curl -sD - google.com | grep '^Date:' | cut -d' ' -f3-6)Z"

  # if not enough space, mount another disk with more space
  # sshfs#root@192.168.2.254:/root/tmp    /root/tmp    fuse    port=22,user,exec,_netdev,noatime,allow_other,nonempty    0  0
  rpi-source -d /tmp

  sed s/jessie/wheezy/ -i /etc/apt/sources.list
  apt-get update
}

function install_rtl8188c_hostapd {
  # 0bda:8176 Realtek Semiconductor Corp. RTL8188CUS 802.11n WLAN Adapter
  echo 'Downloading drivers for Realtek Semiconductor Corp. RTL8188CUS 802.11n WLAN Adapter...'
  [[ ! -f /tmp/RTL8188C.zip ]] && wget http://12244.wpc.azureedge.net/8012244/drivers/rtdrivers/cn/wlan/0001-RTL8188C_8192C_USB_linux_v4.0.2_9000.20130911.zip -O /tmp/RTL8188C.zip

  zipinfo -1 /tmp/RTL8188C.zip *.tar.gz | grep /wpa_supplicant_hostapd- | xargs unzip -p /tmp/RTL8188C.zip | tar xz -C /tmp
  if [ ! -f /etc/hostapd/hostapd.conf ]; then
    zipinfo -1 /tmp/RTL8188C.zip | grep rtl_hostapd_2G.conf | xargs unzip -p /tmp/RTL8188C.zip > /etc/hostapd/hostapd.conf
  fi

  pushd /tmp/wpa_supplicant_hostapd-*/hostapd
  echo 'Compiling hostapd for RTL8188CUS...'
  make
  echo 'Installing hostapd for RTL8188CUS...'
  make install
  cp /usr/local/bin/hostapd /usr/sbin/
  popd
  echo
}

function install_mt7601u_drivers {
  # https://github.com/kuba-moo/mt7601u
  echo 'Downloading drivers for Ralink Technology, Corp. MT7601U 802.11n WLAN Adapter...'
  [[ ! -f /tmp/MT7601U.tar.bz2 ]] && wget http://cdn-cw.mediatek.com/Downloads/linux/DPO_MT7601U_LinuxSTA_3.0.0.4_20130913.tar.bz2 -O /tmp/MT7601U.tar.bz2

  tar xjf /tmp/MT7601U.tar.bz2 -C /tmp

  cp /tmp/DPO_MT7601U_*/mcu/bin/MT7601.bin /lib/firmware/mt7601u.bin

  git clone https://github.com/kuba-moo/mt7601u.git /tmp/mt7601u
  pushd /tmp/mt7601u
  make
  # modprobe mac80211
  # insmod ./mt7601u.ko
  make install && depmod
  popd
}

function install_mt7601u_drivers_bak {
  # http://groenholdt.net/Computers/RaspberryPi/MediaTek-MT7601-USB-WIFI-on-the-Raspberry-Pi/MediaTek-MT7601-USB-WIFI-on-the-Raspberry-Pi.html
  # https://github.com/notro/rpi-source/wiki

  # https://www.raspberrypi.org/forums/viewtopic.php?f=29&t=113753
  # https://github.com/porjo/mt7601
  # https://github.com/kuba-moo/mt7601u

  # rpi-update
  
  # Free some spaces http://blog.samat.org/2015/02/05/slimming-an-existing-raspbian-install/
  apt-get remove -y oracle-java8-jdk

  #sudo apt-get install linux-image-rpi-rpfv linux-headers-rpi-rpfv
  apt-get install linux-headers-$(uname -r)
  apt-get install gcc-4.8 linux-image-3.18.0-trunk-rpi linux-headers-3.18.0-trunk-rpi 
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.6  
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 40 --slave /usr/bin/g++ g++ /usr/bin/g++-4.7
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 40 --slave /usr/bin/g++ g++ /usr/bin/g++-4.8
  update-alternatives --set gcc /usr/bin/gcc-4.8
  #update-alternatives --config gcc

  #ln -s /usr/src/linux-headers-3.18.0-trunk-rpi /lib/modules/`uname -r`/build

  #wget https://github.com/raspberrypi/linux/archive/rpi-4.0.y.zip -O /tmp/rpi.zip
  unzip /tmp/rpi.zip
  mv /tmp/linux-rpi-4.0.y /tmp/linux-rpi
  wget https://raw.github.com/raspberrypi/firmware/master/extra/Module.symvers -O /tmp/linux-rpi/Module.symvers
  pushd /tmp/linux-rpi
  make oldconfig && make prepare
  popd
  ln -s /tmp/linux-rpi/ /lib/modules/`uname -r`/build

  git clone https://github.com/kuba-moo/mt7601u.git /tmp/mt7601
  pushd /tmp/mt7601
  make
  modprobe mac80211
  insmod ./mt7601u.ko
  #mkdir -p /etc/Wireless/RT2870STA/
  #cp RT2870STA.dat /etc/Wireless/RT2870STA/
  #insmod os/linux/mt7601Usta.ko
  popd

  # http://gowthamgowtham.blogspot.fr/2013/11/mediatekralink-wifi-adapter-in.html
  # 148f:7601 Ralink Technology, Corp.
  #echo 'Downloading drivers for Ralink Technology, Corp. MT7601U 802.11n WLAN Adapter...'
  #wget http://cdn-cw.mediatek.com/Downloads/linux/DPO_MT7601U_LinuxSTA_3.0.0.4_20130913.tar.bz2 -O /tmp/MT7601U.tar.bz2

  #tar xjf /tmp/MT7601U.tar.bz2 -C /tmp

  #pushd /tmp/DPO_MT7601U_LinuxSTA_*
  #make
  #make install
  #modprobe mt7601Usta
  #echo "mt7601Usta" | sudo tee -a /etc/modules
  #popd
}

install_rtl8188c_hostapd

free_space
install_raspberry_headers
install_mt7601u_drivers

