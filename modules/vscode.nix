{ pkgs, ... }:

let
  args = {
    enable-crash-reporter = false;
    password-store = "gnome";
  };

in
{
  # home.packages = [ pkgs.vscode ];
  home.file.".vscode/argv.json".text = builtins.toJSON args;
}
