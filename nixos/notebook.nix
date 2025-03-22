# Configuration specific to mobile workstations
{ pkgs, ... }:

{
  services.autorandr = {
    enable = true;
    hooks.postswitch = {
      "set-background" = "${pkgs.feh}/bin/feh --bg-fill ${../home/wallpaper.png}";
    };
  };
  environment.systemPackages = [ pkgs.arandr ];
}
