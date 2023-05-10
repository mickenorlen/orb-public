# open_orb=(
#   "Check if open"
#   ... = ports
# )
# function open() {
#   failed=()

#   for port in "${ports[@]}"; do
#     nmap
#     open="$()"
#     echo $port
#   done
# }

overview_orb=(
  "Get ports overview"
  1 = ip Default: public
  -a = all "all ports"
    Default: true
)
function overview() {
  [[ $ip == public ]] && ip=$(orb ip public)
  echo "Scanning ip: $ip"
  cmd=(sudo nmap -sT)
  $all && cmd+=(-p-)
  # for single ports -p 80,8080
  # no real speed diff
  sudo nmap -sT "$ip" 
}
