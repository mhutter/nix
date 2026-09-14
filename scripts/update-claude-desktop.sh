#!/usr/bin/env bash
set -e -u -o pipefail

NIX_FILE="$(dirname "$0")/../packages/claude-desktop.nix"

FILENAME="$(curl -s "https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-amd64/Packages" | \
  awk '/^Filename: pool\/main\/c\/claude-desktop\/claude-desktop_/{print $2}' | \
  sort -V | \
  tail -n1)"

VERSION="$(echo "$FILENAME" | cut -d'_' -f2)"
URL="https://downloads.claude.ai/claude-desktop/apt/stable/${FILENAME}"

OLD_VERSION="$(sed -n 's/^  version = "\(.*\)";$/\1/p' "$NIX_FILE")"
if [ "$VERSION" = "$OLD_VERSION" ]; then
  echo "claude-desktop is up to date (${VERSION})"
  exit 0
fi

HASH="$(nix store prefetch-file --json --hash-type sha256 "${URL}" | jq -r .hash)"

sed -i \
  -e "s| version = \".*\";\$| version = \"${VERSION}\";|" \
  -e "s| url = \".*\";\$| url = \"${URL}\";|" \
  -e "s| hash = \".*\";\$| hash = \"${HASH}\";|" \
  "$NIX_FILE"

echo "claude-desktop: ${OLD_VERSION} -> ${VERSION}"
