defaultName="Guillaume Girou"
read -p "user.name (default: $defaultName): " username
username=${username:-$defaultName}
read -p "user.email: " useremail

git config --global user.name "$username"
git config --global user.email "$useremail"
# Set git to use the credential memory cache
git config --global credential.helper cache
# Set the cache to timeout after 1 hour (setting is in seconds)
git config --global credential.helper 'cache --timeout=3600'
git config --list

