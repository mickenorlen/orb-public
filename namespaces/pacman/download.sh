#!/bin/bash
# Wget wrapper for pacman with nice progress bar
# Based on https://stackoverflow.com/a/53842799 by maddingl (CC BY-SA 4.0)
#
# Install:
#   sudo cp orb /usr/local/bin/orb
#   sudo chmod +x /usr/local/bin/orb
# In /etc/pacman.conf:
#   XferCommand = /usr/local/bin/orb -o %o %u
/usr/bin/curl -L -C - -f --retry 10 --retry-delay 5 --speed-limit 1 --speed-time 60 -o %o %u

# SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
# source "$SCRIPT_DIR/src/progressbar.sh" || exit 1

# # Parse pacman's arguments: -o %o %u
# OUTPUT=""
# URL=""

# while [[ $# -gt 0 ]]; do
#     case "$1" in
#         -o) OUTPUT="$2"; shift 2 ;;
#         *)  URL="$1"; shift ;;
#     esac
# done

# # Extract filename from URL
# FILENAME="${URL##*/}"
# FILENAME="${FILENAME%%\?*}"

# reformat_and_output_line() {
#     COLS=()
#     for val in $1; do
#         COLS+=("$val")
#     done

#     if [[ ${#COLS[@]} == 9 ]]; then
#         RELATIVE_PROGRESS=${COLS[6]%?}
#         ABSOLUTE_PROGRESS=$(numfmt --from=iec --to=iec-i --format "%.1fB" ${COLS[0]} |
#                             sed 's/\([^[:blank:]]\)\([[:upper:]]\)/\1 \2/')
#         SPEED=$(printf "%+8s" "${COLS[7]}/s")
#         TIME=$(printf "%+5s" ${COLS[8]})
#         progressbar "$FILENAME" "$RELATIVE_PROGRESS" 100 "$ABSOLUTE_PROGRESS" "$SPEED" "$TIME"
#     elif [[ ${#COLS[@]} == 7 ]]; then
#         RELATIVE_PROGRESS=${COLS[5]%?}
#         ABSOLUTE_PROGRESS=$(numfmt --from=iec --to=iec-i --format "%.1fB" ${COLS[0]} |
#                             sed 's/\([^[:blank:]]\)\([[:upper:]]\)/\1 \2/')
#         SPEED=$(printf "%+8s" "$(echo ${COLS[6]} | cut -d= -f1)/s")
#         TIME=$(printf "%+5s" $(echo ${COLS[6]} | cut -d= -f2))
#         progressbar "$FILENAME" "$RELATIVE_PROGRESS" 100 "$ABSOLUTE_PROGRESS" "$SPEED" "$TIME"
#     fi
# }

# wget_like_pacman() {
#     local url="$1"
#     local output="$2"
#     last_output_time=$(( $(date +%s%3N) - 500 ))

#     /usr/bin/wget \
#         --passive-ftp \
#         --tries=10 \
#         --waitretry=5 \
#         --timeout=60 \
#         -c \
#         --quiet \
#         --show-progress \
#         -O "$output" \
#         "$url" 2>&1 | (
#         while IFS= read -r line; do
#             if [[ $(date +%s%3N) -gt $(( last_output_time + 500 )) ]]; then
#                 reformat_and_output_line "${line}"
#                 last_output_time=$(date +%s%3N)
#             fi
#         done
#         printf "\r"
#         reformat_and_output_line "${line}"
#         echo
#     )
# }

# echo -e "\n  :: $FILENAME"
# wget_like_pacman "$URL" "$OUTPUT"
# exit ${PIPESTATUS[0]}
