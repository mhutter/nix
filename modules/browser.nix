{ pkgs, ... }:

let
  firefox = pkgs.firefox;

in
{
  programs.firefox = {
    enable = true;
    package = firefox;
  };
  home.sessionVariables = {
    BROWSER = "${firefox}/bin/firefox";
  };
}
