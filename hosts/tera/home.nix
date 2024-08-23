{ pkgs, ... }:
{
  imports = [
    ../../home
    ../../home/modules/backup.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
