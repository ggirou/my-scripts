# Reconfigure locales
sudo dpkg-reconfigure locales

# Install bash-completion and git
sudo apt-get install -y bash-completion git ca-certificates

# Enable bash completion
echo
echo "#################################################"
echo
echo "Uncomment the following lines in /etc/bash.bashrc"
echo "# enable bash completion in interactive shells"
echo "#if ! shopt -oq posix; then"
echo "#  if [ -f /usr/share/bash-completion/bash_completion ]; then"
echo "#    . /usr/share/bash-completion/bash_completion"
echo "#  elif [ -f /etc/bash_completion ]; then"
echo "#    . /etc/bash_completion"
echo "#  fi"
echo "#fi"
echo
read -n1 -r -p "Press any key to edit /etc/bash.bashrc..." key
sudo nano /etc/bash.bashrc

# Change pi pasword
echo
echo "#################################################"
echo
read -n1 -r -p "Press any key to change user password..." key
sudo passwd pi
