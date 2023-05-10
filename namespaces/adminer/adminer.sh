start_orb=(
  "Start adminer"
	
  -r = restart
	-i = idle
); function start() {
  cd "$docker"
  orb_pass orb docker start -- -ri
}

stop_orb=(
  "Stop adminer"

	-r = restart
	-i = idle
); function stop() {
  cd "$docker"
  orb_pass orb docker stop -- -ri
}
