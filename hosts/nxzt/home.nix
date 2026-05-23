{ pkgs, osConfig, ... }:
{
  imports = [
    ../../home
  ];

  home.programs.lutris = {
    enable = true;
    extraPackages = with pkgs; [
      libnghttp2
      winetricks
    ];
    steamPackage = osConfig.programs.steam.package;
  };
}
