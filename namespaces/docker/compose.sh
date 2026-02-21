# Containers
# start
start_orb=(
	"Start containers"

	-e 1 = env
		Default: IfPresent: '$ORB_DEFAULT_ENV || development'
		In: production staging development
	-s 1 = service "start single service"
	-i = idle
	-r = restart "stop first"
	-d = daemon
		Default: true
	-d- = compose_opts "docker compose opts"
	-o- = up_opts "docker compose up options"
);
function start() {
	docker ps > /dev/null 2>&1 || sudo systemctl start docker

	$restart && orb_pass orb docker stop -- -es

	local cmd=($(orb_pass orb docker compose_cmd -- -ei -d-))
	orb_pass -va cmd up -- -d -o-
	[[ -n $service ]] && cmd+=(--no-deps $service)

	orb_pass -x orb docker set_current_env -- -e

	"${cmd[@]}"
	
	$idle && find /tmp -maxdepth 1 -mindepth 1 -name 'orb-docker-compose.idle.yml*' -exec rm {} \;
}

# start
config_orb=(
	"Container config"

	-e 1 = env
		Default: IfPresent: '$ORB_DEFAULT_ENV || development'
		In: production staging development
	-i = idle
	-d- = compose_opts "docker compose opts"
	-o- = up_opts "docker compose up options"
);
function config() {
	local cmd=($(orb_pass orb docker compose_cmd -- -ei -d-))
	orb_pass -va cmd config -- -o-

	orb_pass -x orb docker set_current_env -- -e

	"${cmd[@]}"
}

# stop
stop_orb=(
	"Stop containers"
	
	-e 1 = env
		Default: IfPresent: '$ORB_DEFAULT_ENV || development'
		In: production staging development
	-s 1 = service "start single service"
	-d- = compose_opts "docker compose opts"
	-o- = up_opts "docker compose up options"
);
function stop() {
	local cmd=($(orb_pass orb docker compose_cmd -- -e -d-))
	orb_pass -va cmd stop -- -s -o-
	orb_pass -x orb docker set_current_env -- -e


	"${cmd[@]}"
}

# logs
logs_orb=(
	"Get container log"

	-e 1 = env
		Default: IfPresent: '$ORB_DEFAULT_ENV || development'
		In: production staging development
	-s 1 = service
		Default: IfPresent: '$ORB_DEFAULT_SERVICE'
		Required: true
	-f = follow
		Default: true
	-l 1 = lines
		Default: 300
	-d- = compose_opts "docker compose opts"
	-o- = up_opts "docker compose up options"
);
function logs() {
	local cmd=($(orb_pass orb docker compose_cmd -- -e -d-))
	orb_pass -va cmd logs -- -f -o-
	cmd+=(--tail "$lines" $service)
	orb_pass -x orb docker set_current_env -- -e

	"${cmd[@]}"
}

# clearlogs
clearlogs_orb=(
	"Clear container logs"

	-e 1 = env
		In: production staging development
	-s 1 = service
		Required: true
	-d- = compose_opts "docker compose opts"
);
function clearlogs() { #
	local id=$(orb_pass orb docker service_id -- -es -d-)
	sudo truncate -s 0 $(docker inspect --format='{{.LogPath}}' "$id")
}

# rm
rm_orb=(
	"Rm containers"

	-e 1 = env
		Default: IfPresent: '$ORB_DEFAULT_ENV || development'
		In: production staging development
	-s 1 = service 'rm single service'
	-d- = compose_opts 'docker compose options'
	-o- = rm_opts 'compose rm options'
	--force = force
		Default: true
);
function rm() {
	orb_pass -x orb docker set_current_env -- -e

	local cmd=($(orb_pass orb docker compose_cmd -- -e -d-))
  orb_pass -va cmd rm -- --force -o- -s
	orb_pass -x orb docker set_current_env -- -e

	"${cmd[@]}"
}

# pull
pull_orb=(
	"Pull compose project images"

	-e 1 = env
		Default: IfPresent: '$ORB_DEFAULT_ENV || development'
		In: production staging development
	-d- = compose_opts 'docker compose options'
	-o- = pull_opts 'compose pull options'
); 
function pull() {
	orb_pass -x orb docker set_current_env -- -e

	local cmd=($(orb_pass orb docker compose_cmd -- -e -d-))
	orb_pass -va cmd pull -- -o-

	"${cmd[@]}"
}

# service_id
service_id_orb=(
	"Get service id"

		-e 1 = env
		Default: IfPresent: '$ORB_DEFAULT_ENV || development'
		In: production staging development
	-s 1 = service 'service to id'
		Default: IfPresent: '$ORB_DEFAULT_SERVICE'
		Required: true
	-d- = compose_opts 'docker compose options'
	-o- = ps_opts 'compose ps -q options'
); 
function service_id() {
	orb_pass -x orb docker set_current_env -- -e
	local cmd=($(orb_pass orb docker compose_cmd -- -e -d-))
	orb_pass -va cmd ps -q -- -o- -s

	"${cmd[@]}"
}

# sh
sh_orb=(
	"Enter container shell or exec cmd"

	-e 1 = env
		Default: IfPresent: '$ORB_DEFAULT_ENV || development'
		In: production staging development
	-s 1 = service 'service to id'
		Default: "$ORB_DEFAULT_SERVICE"
		Required: true
	-u 1 = user
	-d = detached "detached, using run"
	-t = tty
		Default: true
	-i = interactive "interactive, disable if job management error"
		Default: true
	-d- = compose_opts "docker compose options"
	... = input_cmd
		Required: false
); 
function sh() {
	# detached
	local cmd=()

	if $detached; then
		orb_pass -x orb docker set_current_env -- -e
		cmd+=(
			$(orb_pass orb docker compose_cmd -- -e -d-)
			run --no-deps --rm $service
		)
	else
		cmd+=( docker exec -i )
		orb_pass -a cmd -- -tu
		
		local service_id="$(orb_pass orb docker service_id -- -es -d- 2>/dev/null)"

		if [[ -z $service_id ]]; then
			if [ $env == development ]; then
				# Autostart idle container in development
				orb docker start -i -e $env
				service_id="$(orb_pass orb docker service_id -- -es -d-)"
			else
				orb_raise_error "No running container for service $service"
			fi
		fi

		cmd+=( $service_id )
	fi

	local flags=""
	$interactive && flags="-i"

	# Call correct container shell.
	# Stay in container shell after cmd exit for development
	local script='
SHELL_BIN=$(command -v zsh || command -v bash || command -v sh)

FLAGS="$1"
CMD="$2"
ENV="$3"

if [ -n "$CMD" ]; then
  if [ "$ENV" = "development" ]; then
    exec "$SHELL_BIN" $FLAGS -c "$CMD; exec $SHELL_BIN"
  else
    exec "$SHELL_BIN" $FLAGS -c "$CMD"
  fi
else
  exec "$SHELL_BIN" $FLAGS
fi
'

	cmd+=( sh -c "$script" _ "$flags" "${input_cmd[*]}" "$env" )

	"${cmd[@]}"
}

##########
# HELPERS
##########
# compose_cmd
compose_cmd_orb=(
	"Init compose_cmd with correct compose files"

	-e 1 = env
		Default: IfPresent: '$ORB_DEFAULT_ENV'
		In: production staging development
		Required: true
	-i = idle
	-o- = compose_opts_override
		Default: IfPresent: '$COMPOSE_OPTIONS_OVERRIDE'
	-d- = compose_opts_add
); function compose_cmd() {
	local cmd=() compose_cmd="docker compose"
	which docker-compose >/dev/null && compose_cmd=docker-compose

	orb_pass -va cmd $compose_cmd -- -o- -d-

	if [[ -z "${compose_opts_override[@]}" ]]; then
		if [[ -f "docker-compose.$env.yml" ]]; then
			cmd+=( -f docker-compose.yml -f docker-compose.$env.yml )

			if $idle; then
				local tmp="$(build_idle_yml $ORB_DEFAULT_SERVICE)"
				cmd+=( -f "$tmp" )
			fi
		fi
	fi

	echo "${cmd[@]}" # return cmd to stdout
}

build_idle_yml() {
  [ $# == 0 ] && orb_raise_error  "No service provided"
  local services=("$@")
  local idle_msg="Started idle"
  local idle_cmd="sh -c \"echo $idle_msg && tail -f /dev/null\""

  local output_file="$(mktemp /tmp/orb-docker-compose.idle.yml.XXXXXX)"

  local service content="services:"
  for service in "${services[@]}"; do
    content+="
  ${service}:
    command: $idle_cmd"
  done

  echo -e "$content" > "$output_file"
  echo "$output_file"
}

# set_current_env
set_current_env_orb=(
	"export current env vars"

	-e 1 = env 
		Default: IfPresent: '$ORB_DEFAULT_ENV || development'
		In: production staging development
); function set_current_env() { # 
	export ORB_CURRENT_ENV="$env"
	export ORB_CURRENT_ID=$(id -u)
	export ORB_CURRENT_GID=$(id -g)
}

