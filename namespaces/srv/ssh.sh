# ssh
ssh_orb=(
	"Run command on remote"

	1 = subpath
		In: production staging nginx adminer
		Required: false
	-t = tty 
		Default: true
	-u 1 = user 
		Default: IfPresent: '$ORB_SRV_USER'
		Required: true
	-d 1 = domain 
		Default: IfPresent: '$ORB_SRV_DOMAIN'	
		Required: true
	-P 1 = path 
		Default: IfPresent: '$ORB_SRV_REPO_PATH'
		Required: true
	-p 1 = port 
		Default: IfPresent: '$ORB_SRV_PORT'
	... = input_cmd
		Required: false
); 
function ssh() {
	cmd=( /bin/ssh )
	orb_pass -a cmd -- -tp

	cmd+=(
		"${ORB_SRV_USER}@${ORB_SRV_DOMAIN}" PATH="\$PATH:~/.orb/orb"\;
		cd "$path/$subpath" '&&'
	)

	orb_pass -a cmd -- ...
	[[ -n "${input_cmd[@]}" ]] || cmd+=( /bin/bash )

	"${cmd[@]}"
}

###########
# Remote
###########
mount_orb=(
	"Mount remote to _remote"
)
function mount() {
	if [ -d _remote ]; then
		sshfs -o follow_symlinks ${ORB_SRV_USER}@${ORB_SRV_DOMAIN}:${ORB_SRV_REPO_PATH} _remote
	else
		echo 'No _remote'
	fi
}

umountremote_orb=(
	"Umount _remote"
)
function umount() {
	umount -l _remote
}

updateremotecli_orb=(
	"Update remote orb"
)
function updatecli() {
	orb docker ssh -p ".orb" "orb git pullall"
}
