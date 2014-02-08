# $1 command to get the old value
# $2 Text to print
# $3 Variable to set
function askForNewValue() {
  read -p "$2 [$1]: " $3
  eval "$3=\${$3:-$1}"
}

