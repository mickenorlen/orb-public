public_orb=(
  "Print my public ip"
)
function public() {
  dig +short myip.opendns.com @resolver1.opendns.com
}
