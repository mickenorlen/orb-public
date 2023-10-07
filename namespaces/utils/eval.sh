eval_orb=(
  "Eval command in orb context"
  ... = cmd
)
function eval() {
  builtin eval "${cmd[@]}" 
}
