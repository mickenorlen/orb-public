import_orb=(
  1 = env
)
function import() {
  orb srv ssh cd ${ORB_APP_NAME}/${env} \; orb db dump;
  orb srv mount
  [ -d _dumps ] || mkdir _dumps
  cp _remote/${ORB_APP_NAME}/$env/_dumps/db_dump_${env}.sql _dumps/
  # orb srv umount
  orb start -i
  orb db load $env

  # solidus active storage
  rsync --recursive --delete-after ${ORB_SRV_USER}@${ORB_SRV_DOMAIN}:/home/${ORB_SRV_USER}/${ORB_APP_NAME}/${env}/storage ./;

  # Alchemy uploads and pictures
  rsync --recursive --delete-after ${ORB_SRV_USER}@${ORB_SRV_DOMAIN}:/home/${ORB_SRV_USER}/${ORB_APP_NAME}/${env}/public/pictures ./public/;
  rsync --recursive --delete-after ${ORB_SRV_USER}@${ORB_SRV_DOMAIN}:/home/${ORB_SRV_USER}/${ORB_APP_NAME}/${env}/uploads ./;
}
