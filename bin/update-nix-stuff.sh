#!/usr/bin/env bash
set -e -u -o pipefail

cd ~/.config/home-manager

log() {
  echo -e "\n\033[2m[$(date +%T)]\033[0;33m $*\033[0m"
}

log "Update Nix"
sudo -i nix upgrade-nix

log "Cleaning up old home-manager generations"
home-manager expire-generations "-30 days"

# We do this BEFORE `home-manager switch` since it tends to remove home-manager
# sources (which home-manager will complain about)
log "Cleaning up nix store"
nix-collect-garbage --delete-older-than 30d

log "Updating nixpkgs"
nix-channel --update

log "Updating flakes"
nix flake update

if git diff --quiet flake.lock; then
  log "No changes to flake.lock"
else
  log "flake.lock changed, committing"
  git add flake.lock
  git commit -m "Update system"
fi

log "Switching to new home-manager configuration"
home-manager switch
