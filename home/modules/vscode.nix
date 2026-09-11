{ ... }:

let
  args = {
    enable-crash-reporter = false;
    password-store = "gnome-libsecret";
  };

in
{
  programs.vscode = {
    enable = true;
  };

  home.file.".vscode/argv.json".text = builtins.toJSON args;
}
