currentDM=`cat /etc/X11/default-display-manager`
currentDM=${currentDM#/usr/sbin/}

echo Installed Display Managers:
ls -1 -d /etc/*dm/
read -p "Which one to update [$currentDM]? " DM
DM=${DM:-$currentDM}

echo -e "\033[32mInstalling numlockx package...\033[00m"
sudo apt-get install -y numlockx > /dev/null

file=/etc/$DM/Init/Default
magicPatch='\
if [ -x /usr/bin/numlockx ]; then\
    exec /usr/bin/numlockx on\
fi'

grep -q numlockx $file
if [ $? -ne 0 ]
then 
	echo -e "\033[32mPatching $file file...\033[00m"
	sudo sed -i "$ i$magicPatch\n" $file
else
	echo -e "\033[32mAlready patched $file file\033[00m"
fi

tail $file
