# Move to closest docker-compose
compose_file=$(orb_get_closest_parent docker-compose.yml)

if [[ -n  "$compose_file" ]]; then
  # https://stackoverflow.com/a/4170409
	compose_path="${compose_file%\/*}"
	cd "$compose_path"

# compose functions require docker-compose.yml
elif [[ "${_orb_script_file}" == "compose.sh" ]]; then
	_orb_raise_error "requires docker-compose.yml"
fi

# Parse .env
if [ -f '.env.orb' ]; then
	orb_parse_env .env.orb
fi
