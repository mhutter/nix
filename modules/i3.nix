# Module to manage i3-related configurations
#
# Note that this module does NOT manage i3 itself, this is installed via the
# os-native package manager.
{ lib, pkgs, config, ... }:

let
  home = config.home.homeDirectory;
in
{
  # TODO: find a better solution that substituteAll
  home.file.".config/i3/config".source = pkgs.substituteAll {
    src = ../dotfiles/i3;
    inherit home;
    inherit (pkgs) dmenu feh;
    # variables containing dashes break substituteAll :facepalm:
    i3status = pkgs.i3status-rust;
  };

  programs.i3status-rust = {
    enable = true;
    bars.default = {
      theme = "nord-dark";
      icons = "awesome4";
      blocks = [
        {
          block = "custom";
          command = "echo '\\uf135' $(cat /sys/firmware/acpi/platform_profile)";
          click = [{
            button = "left";
            sync = true;
            update = true;
            cmd = ''
              P=/sys/firmware/acpi/platform_profile
              case "$(cat "$P")" in
                balanced)
                  echo performance | sudo tee "$P"
                ;;
                *)
                  echo balanced | sudo tee "$P"
                ;;
              esac
            '';
          }];
        }
        {
          block = "custom";
          command = "echo '\\uf0ac' $(curl -sS https://ipecho.net/plain)";
          interval = 3600;
        }
        {
          block = "net";
          # device = "wlan0";
          format = "$icon {$signal_strength SSID @$frequency|Wired connection} via $device ";
          interval = 5;
        }
        {
          block = "disk_space";
          path = "/";
          format = "$icon $available.eng(w:2) ";
          info_type = "available";
          alert_unit = "GB";
          interval = 20;
          warning = 20.0;
          alert = 10.0;
        }
        {
          block = "memory";
          format = "$icon$mem_used_percents ";
        }
        {
          block = "cpu";
          interval = 1;
        }
        {
          block = "load";
          interval = 1;
          format = "$1m ";
        }
        {
          block = "sound";
        }
        {
          block = "battery";
          interval = 10;
          format = "$icon $percentage $time ";
        }
        {
          block = "time";
          interval = 5;
          format = " $timestamp.datetime(f:'%a %d/%m %R') ";
        }
      ];
    };
  };
}
