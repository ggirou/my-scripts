read -p "Key label: " label

cd ~/.ssh
# Creates a new ssh key, using the provided label
ssh-keygen -t rsa -C "$label"
ssh-add id_rsa

