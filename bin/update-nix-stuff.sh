# shellcheck shell=bash
set -e -u -o pipefail

cd ~/.config/home-manager

log() {
  echo -e "\033[2m[$(date +%T)]\033[0;33m $*\033[0m"
}

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

log "Cleaning up old home-manager generations"
home-manager expire-generations "-30 days"

# log "Cleaning up nix store"
# nix-collect-garbage --delete-older-than 30d

# log "Fix Nix store permissions"
# sudo chmod -R -w /nix/store

log "Optimize Nix store"
nix store optimise
