# Move to closest .env.orb
envorb="$(orb_get_closest_parent .env.orb)"

if [[ -n  "$envorb" ]]; then
  # https://stackoverflow.com/a/4170409
	envorb_path="${envorb%\/*}"
	cd "$envorb_path"

	# Parse .env
	# if [ -f '.env.orb' ]; then
	orb_parse_env "$envorb"
	# fi

# requires docker-compose.yml
else 
	orb_raise_error "requires .env.orb"
fi

