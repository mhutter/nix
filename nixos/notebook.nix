# Configuration specific to mobile workstations
{ pkgs, ... }:

{
  services.autorandr = {
    enable = true;
    hooks.postswitch = {
      "set-background" = "${pkgs.feh}/bin/feh --fill-bg ${../home/wallpaper.png}";
    };
  };
  environment.systemPackages = [ pkgs.arandr ];
}
