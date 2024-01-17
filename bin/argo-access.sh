#!/usr/bin/env bash
set -e -u -o pipefail

KUBECTL=kubectl
if [ "$1" = "-o" ]; then
  shift
  KUBECTL='kubectl --as=cluster-admin'
fi

$KUBECTL -n syn get secret/steward -o json "$@" | \
  jq -r '.data.token | @base64d' | \
  xclip

xdg-open 'http://localhost:8080/'

$KUBECTL "$@" -n syn port-forward svc/syn-argocd-server 8080:80
