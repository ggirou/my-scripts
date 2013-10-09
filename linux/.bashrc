# Bash prompt extension showing the current git branch
export PS1='\[\033[01;32m\]\u:\[\033[31m\]$(__git_ps1 "(%s)")\[\033[01;34m\]\w \[\033[01;34m\]$\[\033[00m\] '

# Git alias
alias ga='git add'
alias gp='git push'
alias gl='git log'
alias gs='git status'
alias gd='git diff'
alias gm='git commit -m'
alias gma='git commit -am'
alias gb='git branch'
alias gc='git checkout'
alias gra='git remote add'
alias grr='git remote rm'
alias gpu='git pull'
alias gcl='git clone'

