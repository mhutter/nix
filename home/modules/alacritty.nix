{ pkgs, ... }:
{
  # Note: There is a `programs.alacritty` module in HomeManager, but this would
  # also _install_ alacritty which we do not want on non-NixOS systems.
  xdg.configFile."alacritty/alacritty.toml".source =
    (pkgs.formats.toml { }).generate "alacritty-config"
      {
        colors = {
          primary = {
            background = "#1b2b34";
            foreground = "#c0c5ce";
          };
          cursor = {
            cursor = "#c0c5ce";
            text = "#1b2b34";
          };
          normal = {
            black = "#1b2b34";
            blue = "#6699cc";
            cyan = "#5fb3b3";
            green = "#99c794";
            magenta = "#c594c5";
            red = "#ec5f67";
            white = "#c0c5ce";
            yellow = "#fac863";
          };
          bright = {
            black = "#65737e";
            blue = "#6699cc";
            cyan = "#5fb3b3";
            green = "#99c794";
            magenta = "#c594c5";
            red = "#ec5f67";
            white = "#d8dee9";
            yellow = "#fac863";
          };
        };

        cursor.style.blinking = "Always";

        font = {
          size = 11;
          normal.family = "DejaVuSansM Nerd Font";
        };

        keyboard.bindings = [
          {
            action = "SpawnNewInstance";
            key = "Return";
            mods = "Control|Shift";
          }
        ];
      };
}
