#!/usr/bin/env bash
set -e -u -o pipefail

cd ~/.config/nix

log() {
  echo -e "\n\033[2m[$(date +%T)]\033[0;33m $*\033[0m"
}

is_nixos() {
  test -f /etc/NIXOS
}

if !is_nixos; then
  log "Update Nix"
  sudo -i nix upgrade-nix

  log "Cleaning up old home-manager generations"
  home-manager expire-generations "-30 days"

fi

# We do this BEFORE `home-manager switch` since it tends to remove home-manager
# sources (which home-manager will complain about)
log "Cleaning up nix store"
nix-collect-garbage --delete-older-than 30d

log "Updating flakes"
nix flake update

if git diff --quiet flake.lock; then
  log "No changes to flake.lock"
else
  log "flake.lock changed, committing"
  git add flake.lock
  git commit -m "Update system"
fi

if is_nixos; then
  log "Switching to new nixos configuration"
  nixos-rebuild build --flake .

  read -p "Apply changes? " -n 1 -r
  echo
  if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    exit
  fi

  nix store diff-closures /run/current-system ./result
  sudo nixos-rebuild switch --flake .

else
  log "Switching to new home-manager configuration"
  home-manager switch --flake .

fi
