# shellcheck shell=bash
set -e -u -o pipefail

KNOWN_HOSTS='@home@/.ssh/known_hosts'
GREP='@grep@'
SED='@sed@'

count=0

for host in "$@"; do
  count=$((count + $("$GREP" -c "$host " "$KNOWN_HOSTS" || :)))
  "$SED" -i "/$host /d" "$KNOWN_HOSTS"
done

echo "Removed $count entries from $KNOWN_HOSTS"
