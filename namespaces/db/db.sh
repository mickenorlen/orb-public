# dump
dump_orb=(
  "Dump db"

  -e 1 = env "Target env"
    Default: IfPresent: '$ORB_DEFAULT_ENV || development'
    In: production staging development
  -s 1 = service
    Default: db
  -U 1 = dbuser "Db user"
    Default: IfPresent: '$ORB_DATABASE_USERNAME'
  -d 1 = dbname 'Db name'
    Default: Help: '$ORB_APP_NAME_$env'
  -f = force
  -p 1 = project_path 'Folder relative from project root'
    Default: _dumps
); function dump() {
  [[ -z $dbname ]] && dbname="${ORB_APP_NAME}_$env"

  local cmd=()
  orb_pass -a cmd orb docker bash +t +i -- -es
  local cmd+=( 
    su $dbuser -c "postgres > /dev/null 2>&1 & sleep 2s &&
    pg_dump --no-owner --no-acl -U $dbuser $dbname" 
  )

  "${cmd[@]}" > "$project_path/db_dump_$env.sql"
}

# load
load_orb=(
  "Import eg db_dump_production to app_development"

  1 = in_env "Imported db env"
    In: production staging development
  -e 1 = out_env "Target env"
    Default: IfPresent: '$ORB_DEFAULT_ENV || development'
    In: production staging development
  -s 1 = service
    Default: db
  -U 1 = dbuser "Db user"
    Default: IfPresent: '$ORB_DATABASE_USERNAME'
  -d 1 = dbname 'Db name'
    Default: Help: '$ORB_APP_NAME_$env'
  -p 1 = project_path 'Folder relative from project root'
    Default: _dumps
  -f = force
)
function load() { # 
  [[ -z $dbname ]] && dbname="${ORB_APP_NAME}_$out_env"

  if ! $force; then
    echo -n "Empty $dbname in $out_env $service and import $project_path/db_dump_$in_env? y/N: "
    local reply
    read reply
    [[ $reply != "y" ]] && exit
  fi

  local empty_sql=$(cat <<SQL
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO $dbuser;
GRANT ALL ON SCHEMA public TO public;
SQL
)

  local empty_cmd=()
  orb_pass -a empty_cmd orb docker bash -- -es
  empty_cmd+=( "psql -U $dbuser $dbname -c '$empty_sql'" )
  

  local load_cmd=()
  orb_pass -a load_cmd orb docker bash +t -- -es
  load_cmd+=( "psql -U $dbuser -d ${ORB_APP_NAME}_$out_env" )
  
  local output
  # output=
  "${empty_cmd[@]}"
  # &> /dev/null && echo -e "$(_green)db reset(_normal)" || _raise_error +t "failed to empty db - $output"
  output=$("${load_cmd[@]}" < $project_path/db_dump_$in_env.sql) && echo -e "$(orb_green)db loaded$(orb_normal)" || orb_raise_error +t "failed to load db"
  # < db_dump_prod.sql " )

  # 	orb run -s db
	# docker exec -i ${APP_NAME}_dev_db psql -U postgres -d ${APP_NAME}_development < db_dump_prod.sql &> /dev/null

	# orb sh -s db "psql -U $DATABASE_USERNAME ${APP_NAME}_development -c \"$sql\"" &> /dev/null
	# docker exec -i ${APP_NAME}_dev_db psql -U postgres -d ${APP_NAME}_development < db_dump_prod.sql &> /dev/null
}


upgrade_orb=(
  "Upgrade containerized db"
  1 = ver "current version"
  2 = new_ver "next version"
  3 = data "current data"
  4 = new_data "next version data"
)
function upgrade() {
  sudo docker run -it --rm \
      -v $3:/var/lib/postgresql/$1/data \
      -v $4:/var/lib/postgresql/$2/data \
      -e PGUSER=awx -e POSTGRES_INITDB_ARGS="-U awx" \
      tianon/postgres-upgrade:$1-to-$2 bash
}
