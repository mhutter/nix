# Configuration specific to mobile workstations
{ pkgs, username, ... }:

{
  environment.systemPackages = [ pkgs.arandr ];

  programs.light = {
    enable = true;
    brightnessKeys.enable = true;
  };
  users.users.${username}.extraGroups = [ "video" ];

  services.autorandr = {
    enable = true;
    hooks.postswitch = {
      "set-background" = "${pkgs.feh}/bin/feh --bg-fill ${../home/wallpaper.png}";
    };
  };
}
