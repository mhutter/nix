# Configuration specific to mobile workstations
{ pkgs, username, ... }:

{
  environment.systemPackages = [ pkgs.arandr ];

  # TODO: for backlight, investigate `acpilight` or `brightnessctl`.
  users.users.${username}.extraGroups = [ "video" ];

  services.autorandr = {
    enable = true;
    hooks.postswitch = {
      "set-background" = "${pkgs.feh}/bin/feh --bg-fill ${../home/wallpaper.png}";
    };
  };

  hardware.bluetooth.enable = true;
}
