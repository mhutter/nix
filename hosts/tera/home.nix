{ pkgs, ... }:
{
  imports = [
    ../../home.nix
    ../../modules/backup.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.activation.diff = ''
    echo === Profile changes ===
    ${pkgs.home-manager}/bin/home-manager generations | head -n2 | sort | ${pkgs.gawk}/bin/awk '{print $7}' | xargs nix store diff-closures
  '';
}
