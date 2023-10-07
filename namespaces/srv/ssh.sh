# ssh
ssh_orb=(
	"Run command on remote"
	-t = tty 
		Default: true
	-u 1 = user 
		Default: IfPresent: '$ORB_SRV_USER'
		Required: true
	-d 1 = domain 
		Default: IfPresent: '$ORB_SRV_DOMAIN'	
		Required: true
	-P 1 = path 
		Default: '~'
	-p 1 = port 
		Default: IfPresent: '$ORB_SRV_PORT'
	... = input_cmd
		Required: false
); 
function ssh() {
	cmd=( /bin/ssh )
	orb_pass -a cmd -- -tp

	cmd+=("${user}@${domain}")

	orb_pass -a cmd -- ...
	# [[ -n "${input_cmd[@]}" ]] || cmd+=( /bin/bash )

	"${cmd[@]}"
}

###########
# Remote
###########
mount_orb=(
	"Mount remote to _remote"
)
function mount() {
	[ -d _remote ] || mkdir _remote
	sshfs -o follow_symlinks "${ORB_SRV_USER}@${ORB_SRV_DOMAIN}:/home/$ORB_SRV_USER/" _remote
}

umount_orb=(
	"Umount _remote"
)
function umount() {
	# umount -l _remote
	/bin/umount _remote
}

updatecli_orb=(
	"Update remote orb"
)
function updatecli() {
	orb docker ssh -p ".orb" "orb git pullall"
}
