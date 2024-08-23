#!/usr/bin/env bash
set -e -u -o pipefail

while (( $# )); do
  case "$1" in
    -q) quiet=1 ;;
    *)
      if [[ -z "$host" ]]; then
        host="$1"
      elif [[ -z "$port" ]]; then
        port="$1"
      else
        test -z "$quiet" && echo "usage: socks-proxy [-q] HOST PORT" >&2
        exit 1
      fi
      ;;
  esac
  shift
done

if ps -f -C ssh | grep -q " -D $port $host"; then
  test -z "$quiet" && echo "SOCKS proxy already running: $port via $host" >&2
  exit 0
fi

test -z "$quiet" && echo "Starting SOCKS proxy: $port via $host" >&2
ssh -q -f -C -N -D "$port" "$host"
