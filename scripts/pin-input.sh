#!/usr/bin/env bash
set -e -u -o pipefail

usage() {
  echo "$0 INPUT REV"
  echo
  echo "INPUT  Name of the flake input to update"
  echo "REV    Git revision to pin to"
}

if [ "$#" -ne "2" ]; then
  usage
  exit 1
fi

INPUT_NAME="$1"
shift
TARGET_REV="$1"
shift

INPUT="$(jq --arg input "${INPUT_NAME}" '.nodes[$input].locked' flake.lock)"
INPUT_TYPE="$(jq -r '.type' <<<"${INPUT}")"

case "${INPUT_TYPE}" in
  "github")
    ARCHIVE_URL="$(jq -r --arg rev "${TARGET_REV}" '. | "https://github.com/\(.owner)/\(.repo)/archive/\($rev).tar.gz"' <<<"${INPUT}")"
    ;;
  *)
    echo "Unsupported input type: ${INPUT_TYPE}" >&2
    exit 2
    ;;
esac

HASH="$(nix-prefetch-url --unpack "${ARCHIVE_URL}" --name source)"
SRI_HASH="$(nix hash convert --hash-algo sha256 --to sri "${HASH}")"
COMMIT_TIMESTAMP="$(curl -s 'https://api.github.com/repos/nixos/nixpkgs/commits/a672be65651c80d3f592a89b3945466584a22069' | jq '.commit.committer.date' | xargs date +%s -d)"

jq --arg input "${INPUT_NAME}" \
   --arg rev "${TARGET_REV}" \
   --arg narHash "${SRI_HASH}" \
   --argjson lastModified "${COMMIT_TIMESTAMP}" \
   '.nodes[$input].locked += { "rev": $rev, "lastModified": $lastModified, "narHash": $narHash }' \
   flake.lock > flake.lock.tmp
mv flake.lock.tmp flake.lock