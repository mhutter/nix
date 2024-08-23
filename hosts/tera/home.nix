{ config, pkgs, ... }:
let
  configPath = "${config.home.homeDirectory}/.config/nix";

in
{
  imports = [
    ../../home
    ../../home/modules/backup.nix
  ];

  # Let home-manager automatically discover its config
  home.file.".config/home-manager".source = config.lib.file.mkOutOfStoreSymlink configPath;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
