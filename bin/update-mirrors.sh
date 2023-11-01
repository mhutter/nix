# shellcheck shell=bash
set -e -u -o pipefail

export TMPFILE="$(mktemp)"
trap "rm -f '$TMPFILE'" EXIT INT TERM

# Ensure we can `sudo` before running `rate-mirrors`
sudo true

rate-mirrors --save="$TMPFILE" --disable-comments-in-file arch --max-delay=43200

sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup
sudo install --mode=0644 "$TMPFILE" /etc/pacman.d/mirrorlist
