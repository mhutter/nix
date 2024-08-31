# Module to manage i3-related configurations
#
# Note that this module does NOT manage i3 itself, this is installed via the
# os-native package manager.
{ lib, pkgs, config, ... }:

{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    dejavu_fonts
    fira-code
    font-awesome
  ];

  xsession.enable = true;
  xsession.windowManager.i3 =
    let
      i3status = "${pkgs.i3status-rust}/bin/i3status-rs";
      fonts = {
        names = [ "DejaVuSansM Nerd Font" "FontAwesome 11" ];
        style = "Mono";
        size = 10.0;
      };
      mod = "Mod4";
      # Used below. Should be PNG to be used with i3lock
      wallpaper = ../wallpaper.png;

      # Colors
      bg-color = "#2f343f";
      inactive-bg-color = "#2f343f";
      text-color = "#f3f4f5";
      inactive-text-color = "#676e7d";
      urgent-bg-color = "#e53935";
      indicator = "";
      childBorder = "";

    in
    {
      enable = true;
      config = {
        inherit fonts;
        modifier = mod;
        floating.modifier = mod;

        startup = [
          # Start `wired` notification daemon
          # FIXME: Replace with something that is in nixpkgs OR create flake
          { command = "wired"; notification = false; }
          # Set background image
          { command = "${pkgs.feh}/bin/feh --bg-fill ${wallpaper}"; notification = false; }
          # Start XDG autostart .desktop files using dex. See also
          # https://wiki.archlinux.org/index.php/XDG_Autostart
          { command = "${pkgs.dex}/bin/dex --autostart --environment i3"; notification = false; }
        ];

        bars = [{
          inherit (config.xsession.windowManager.i3.config) fonts;
          statusCommand = "${i3status} config-default.toml";
          colors = {
            # background $bg-color
            # separator #757575
            #                    border             background         text
            # focused_workspace  $bg-color          $bg-color          $text-color
            # inactive_workspace $inactive-bg-color $inactive-bg-color $inactive-text-color
            # urgent_workspace   $urgent-bg-color   $urgent-bg-color   $text-color
            background = bg-color;
            separator = "#757575";
            focusedWorkspace = {
              border = bg-color;
              background = bg-color;
              text = text-color;
            };
            inactiveWorkspace = {
              border = inactive-bg-color;
              background = inactive-bg-color;
              text = inactive-text-color;
            };
            urgentWorkspace = {
              border = urgent-bg-color;
              background = urgent-bg-color;
              text = text-color;
            };
          };
        }];

        keybindings = lib.mkOptionDefault {
          # Make media keys work
          "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10%";
          "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10%";
          "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";

          # use VIM keybindings for focus
          "${mod}+h" = "focus left";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";

          # use VIM keybindings for movement
          "${mod}+Shift+h" = "move left";
          "${mod}+Shift+j" = "move down";
          "${mod}+Shift+k" = "move up";
          "${mod}+Shift+l" = "move right";

          # Split in horizontal direction (default is mod+h, which is already taken by focus commands)
          "${mod}+Shift+v" = "split h";

          # Lock the screen
          # IMPORTANT: Unlocking does not work on Arch when using the nixpkgs i3lock.
          "${mod}+Shift+x" = "exec i3lock -i ${wallpaper}";
        };

        modes.resize = lib.mkOptionDefault {
          "h" = "resize shrink width 10 px or 10 ppt";
          "j" = "resize grow height 10 px or 10 ppt";
          "k" = "resize shrink height 10 px or 10 ppt";
          "l" = "resize grow width 10 px or 10 ppt";
        };

        colors = {
          # window colors
          #                         border              background         text                 indicator
          # client.focused          $bg-color           $bg-color          $text-color          #00ff00
          # client.unfocused        $inactive-bg-color  $inactive-bg-color $inactive-text-color #00ff00
          # client.focused_inactive $inactive-bg-color  $inactive-bg-color $inactive-text-color #00ff00
          # client.urgent           $urgent-bg-color    $urgent-bg-color   $text-color          #00ff00
          focused = {
            border = bg-color;
            background = bg-color;
            text = text-color;
            inherit indicator childBorder;
          };
          unfocused = {
            border = inactive-bg-color;
            background = inactive-bg-color;
            text = inactive-text-color;
            inherit indicator childBorder;
          };
          focusedInactive = {
            border = inactive-bg-color;
            background = inactive-bg-color;
            text = inactive-text-color;
            inherit indicator childBorder;
          };
          urgent = {
            border = urgent-bg-color;
            background = urgent-bg-color;
            text = text-color;
            inherit indicator childBorder;
          };

        };

        window.commands = [
          # Custom window configs - use `xprop` to find the properties
          { criteria = { class = "(?i)nm-connection-editor"; }; command = "floating enable"; }
          { criteria = { class = "Imager"; }; command = "floating enable"; }
          { criteria = { class = "Qemu-system-x86_64"; }; command = "floating enable"; }
          { criteria = { class = "XCalc"; }; command = "floating enable"; }
          { criteria = { class = "Gnuplot"; }; command = "floating enable"; }

          # Zoom - there are a lot of small popup windows, so we set
          # EVERYTHING to float, and only disable it for the main- and meeting
          # window
          { criteria = { class = "zoom"; }; command = "floating enable"; }
          { criteria = { class = "zoom"; title = "Zoom Workplace - .*"; }; command = "floating disable"; }
          { criteria = { class = "zoom"; title = "Meeting"; }; command = "floating disable"; }
        ];
      };
    };

  programs.i3status-rust = {
    enable = true;
    bars.default = {
      theme = "nord-dark";
      icons = "awesome6";
      blocks = [
        {
          block = "custom";
          command = "echo '\\uf135' $(cat /sys/firmware/acpi/platform_profile)";
          click = [
            {
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
            }
            {
              button = "right";
              sync = true;
              update = true;
              cmd = ''
                P=/sys/firmware/acpi/platform_profile
                case "$(cat "$P")" in
                  balanced)
                    echo low-power | sudo tee "$P"
                  ;;
                  *)
                    echo balanced | sudo tee "$P"
                  ;;
                esac
              '';
            }
          ];
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
