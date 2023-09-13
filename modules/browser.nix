{ pkgs, ... }:

let

in
{
  home.sessionVariables = {
    BROWSER = "chromium";
  };
}
