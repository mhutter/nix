# Configuration specific to mobile workstations
{ pkgs, username, ... }:

{
  environment.systemPackages = [
    pkgs.arandr
    # Backlight control for the XF86MonBrightness* keys bound in home/modules/i3.nix.
    # No udev rules needed, it writes brightness through the systemd-logind API.
    pkgs.brightnessctl
  ];

  users.users.${username}.extraGroups = [ "video" ];

  services.autorandr = {
    enable = true;
    hooks.postswitch = {
      "set-background" = "${pkgs.feh}/bin/feh --bg-fill ${../home/wallpaper.png}";
    };
  };

  hardware.bluetooth.enable = true;
}
