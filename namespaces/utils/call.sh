call_orb=(
  "Call command in orb context"
  ... = cmd
)
function call() {
  "${cmd[*]}" 
}
