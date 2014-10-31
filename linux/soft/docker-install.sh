sudo apt-get install cgroup-lite apparmor
curl -sSL https://get.docker.com/ubuntu/ | sudo sh

# Add the docker group if it doesn't already exist.
sudo groupadd docker

# Add the connected user "${USER}" to the docker group.
sudo gpasswd -a ${USER} docker

# Docker and UFW
sed -r -i "s|DEFAULT_FORWARD_POLICY=.+$|DEFAULT_FORWARD_POLICY=\"ACCEPT\"|g" /etc/default/ufw
sudo ufw reload
sudo ufw allow 2375/tcp

# Restart the Docker daemon.
sudo service docker restart
