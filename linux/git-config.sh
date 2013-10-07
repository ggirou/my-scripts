usernameBak=`git config --global user.name`
useremailBak=`git config --global user.email`
read -p "user.name [$usernameBak]: " username
read -p "user.email [$useremailBak]: " useremail
username=${username:-$usernameBak}
useremail=${useremail:-$useremailBak}

git config --global user.name "$username"
git config --global user.email "$useremail"
# Set git to use the credential memory cache
git config --global credential.helper cache
# Set the cache to timeout after 1 hour (setting is in seconds)
git config --global credential.helper 'cache --timeout=3600'
git config --global push.default simple
# Set a log alias "git lg" (https://coderwall.com/p/euwpig)
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
echo -------------------------------------------------------------------------------
git config --list

