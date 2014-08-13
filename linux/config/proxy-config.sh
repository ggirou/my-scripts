#!/bin/bash

source ${BASH_SOURCE%/*}/../utils/commons.sh

askForNewValue "$HTTP_PROXY" "HTTP_PROXY" HTTP_PROXY
askForNewValue "$NO_PROXY" "NO_PROXY" NO_PROXY

TMP=`cat <<EOF
HTTP_PROXY=$HTTP_PROXY
HTTPS_PROXY=$HTTP_PROXY
FTP_PROXY=$HTTP_PROXY
NO_PROXY=$NO_PROXY
http_proxy=$HTTP_PROXY
https_proxy=$HTTP_PROXY
ftp_proxy=$HTTP_PROXY
no_proxy=$NO_PROXY
EOF`

echo 'Save in /etc/environment...'
sudo sed -i '/proxy=/Id' /etc/environment
sudo sh -c "echo '$TMP' >> /etc/environment"

TMP=`cat <<EOF
Acquire::http::proxy "$HTTP_PROXY";
Acquire::https::proxy "$HTTP_PROXY";
Acquire::ftp::proxy "$HTTP_PROXY";
EOF`

echo 'Save in /etc/apt/apt.conf.d/95proxies...'
sudo sed -i '/::proxy/Id' /etc/apt/apt.conf.d/95proxies
sudo sh -c "echo '$TMP' >> /etc/apt/apt.conf.d/95proxies"

if dpkg -s git &> /dev/null; then
	echo 'Configure git'
	git config --global http.proxy "$HTTP_PROXY"
	git config --global https.proxy "$HTTP_PROXY"
fi

