{ pkgs, ... }:
{
  imports = [
    ../../home
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      cursor.style.blinking = "Always";

      font = {
        size = 11;
        normal.family = "DejaVuSansM Nerd Font";
      };

      colors = {
        primary = {
          background = "#1b2b34";
          foreground = "#c0c5ce";
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

        cursor = {
          cursor = "#c0c5ce";
          text = "#1b2b34";
        };

      };
    };
  };
}
