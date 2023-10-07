# confirm
confirm_orb=(
  1 = question "question to confirm"
); function confirm() {
  echo -ne "$question (y/N) "
  local reply
  read reply
  
  [[ $reply == "y" ]]
  return $? 
}
