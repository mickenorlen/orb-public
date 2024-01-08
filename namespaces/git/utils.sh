forget_orb=(
  1 = file 'file to forget'
  -f = force
); function forget() { # Completely forget file from local branch history (with confirmation prompt)
	validate_is_repo
	[ -e "$file" ] || orb core orb_raise_error +t "file not found"

	if orb prompt confirm "Forget $file?"; then
    $force && flags="-f"
    echo "Forgetting $file"
    git filter-branch $flags --index-filter "git rm -rf --cached --ignore-unmatch $file" HEAD
  fi
}

function validate_is_repo() { # Check if in git repo
	local validate_is_repo=$([ -d .git ] && echo .git || git rev-parse --git-dir > /dev/null 2>&1)
	[[ -z "$validate_is_repo" ]] && orb core orb_raise_error 'not in git repo'
}

function pullall() { # Pull all updates including submodules
  git pull && git submodule update && git submodule status
}

# commitall
commitall_orb=(
  1 = msg
); 
function commitall() {
  git submodule foreach bash -c "orb git has_uncommitted && git add . && git commit -m \"$msg\" || :"

  if orb git has_uncommitted; then
    git add .
    git commit -m "$1"
  fi
}

function pushall() {
  git submodule foreach git push
  git push
}

function has_uncommitted() {
  ! git diff-index --quiet HEAD --
}

save_orb=(
  "Add, commit, push"
  1 = commit_msg Default: Save  
)
function save() {
  git add . && \
  git commit -m "$commit_msg" && \
  git push
}
