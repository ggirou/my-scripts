usernameBak=`git config --global user.name`
useremailBak=`git config --global user.email`
mergetoolBak=`git config --global merge.tool`
read -p "user.name [$usernameBak]: " username
read -p "user.email [$useremailBak]: " useremail

git mergetool --tool-help
read -p "merge.tool [$mergetoolBak]: " mergetool
username=${username:-$usernameBak}
useremail=${useremail:-$useremailBak}
mergetoolBak=${mergetool:-$mergetoolBakBak}

git config --global user.name "$username"
git config --global user.email "$useremail"
# Set the merge tool
git config --global merge.tool "$mergetool"
# Set git to use the credential memory cache
git config --global credential.helper cache
# Set the cache to timeout after 1 hour (setting is in seconds)
git config --global credential.helper 'cache --timeout=3600'
git config --global push.default simple
# Add some colors to ui
git config --global color.ui true
# ALIAS
# Set a log alias "git lg" (https://coderwall.com/p/euwpig)
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
# Set a diff alias more tolerant
git config --global alias.dif 'diff --ignore-space-change --color-words'
# Set a stash alias to only stash unstaged files
git config --global alias.stash-unstaged 'stash --keep-index'


echo -------------------------------------------------------------------------------
git config --list

