call_orb=(
  "Call command in orb context"
  ... = cmd
)
function call() {
  bash -c "${cmd[*]}" 
}
