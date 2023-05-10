# Move to closest docker-compose
compose_file="$(orb_get_closest_parent docker-compose.yml)"

if [[ -n  "$compose_file" ]]; then
  # https://stackoverflow.com/a/4170409
	compose_path="${compose_file%\/*}"
	cd "$compose_path"

	# Parse .env
	if [ -f '.env.orb' ]; then
		orb_parse_env .env.orb
	fi

# requires docker-compose.yml
else 
	orb_raise_error "requires docker-compose.yml"
fi

