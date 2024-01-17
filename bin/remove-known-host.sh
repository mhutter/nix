#!/usr/bin/env bash
set -e -u -o pipefail

KNOWN_HOSTS="${HOME}/.ssh/known_hosts"

count=0

for host in "$@"; do
  count=$((count + $(grep -c "$host " "$KNOWN_HOSTS" || :)))
  sed -i "/$host /d" "$KNOWN_HOSTS"
done

echo "Removed $count entries from $KNOWN_HOSTS"
