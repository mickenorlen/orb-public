# Load own namespaces, any nested index.sh will only be called when namespace is invoked
orb_add_namespaces "$ORB_PWD/namespaces"
# Load own env
orb_add_env "$ORB_PWD/.env"
orb_add_env .ssh.env "$ORB_PWD/.env" ssh
