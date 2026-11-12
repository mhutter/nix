{ pkgs, ... }:
{
  hardware.graphics.enable32Bit = true;
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    remotePlay.openFirewall = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
}
