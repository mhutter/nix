{ pkgs, ... }:

let
  args = {
    enable-crash-reporter = false;
    password-store = "gnome-libsecret";
  };

in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhsWithPackages (
      ps: with ps; [
        # add extra dependencies here
      ]
    );
  };

  home.file.".vscode/argv.json".text = builtins.toJSON args;
}
