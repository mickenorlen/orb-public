#!/bin/bash
orb_get_closest_parent() {
  local filename="$1"
  local dir="${2:-$PWD}"

  # Normalize to absolute path
  dir="$(cd "$dir" 2>/dev/null && pwd)" || return 1

  while [[ -n "$dir" ]]; do
    if [[ -f "$dir/$filename" ]]; then
      echo "$dir/$filename"
      return 0
    fi
    # Stop at root
    [[ "$dir" == "/" ]] && break
    dir="${dir%/*}"
    [[ -z "$dir" ]] && dir="/"
  done

  return 1
}

orb_parse_env() {
  local env_file="$1"

  if [[ ! -f "$env_file" ]]; then
    return 1
  fi

  local line key value
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Strip leading/trailing whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    # Skip blank lines and full-line comments
    [[ -z "$line" || "$line" == \#* ]] && continue

    # Must look like KEY=VALUE
    [[ "$line" != *"="* ]] && continue

    key="${line%%=*}"
    value="${line#*=}"

    # Trim whitespace around key
    key="${key%"${key##*[![:space:]]}"}"

    # Strip inline comment (unquoted # preceded by whitespace)
    if [[ "$value" != \"*\" && "$value" != \'*\' ]]; then
      value="${value%%[[:space:]]#*}"
    fi

    # Trim trailing/leading whitespace from value
    value="${value%"${value##*[![:space:]]}"}"
    value="${value#"${value%%[![:space:]]*}"}"

    # Strip surrounding quotes
    if [[ "$value" == \"*\" && "$value" == *\" ]]; then
      value="${value#\"}"
      value="${value%\"}"
    elif [[ "$value" == \'*\' && "$value" == *\' ]]; then
      value="${value#\'}"
      value="${value%\'}"
    fi

    # Expand $$VARNAME placeholders using already-exported vars
    while [[ "$value" =~ \$\$([A-Za-z_][A-Za-z0-9_]*) ]]; do
      local ref="${BASH_REMATCH[1]}"
      local ref_val="${!ref}"
      value="${value//\$\$$ref/$ref_val}"
    done

    export "$key=$value"
  done < "$env_file"
}
