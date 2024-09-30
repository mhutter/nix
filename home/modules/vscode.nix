{ pkgs, ... }:

let
  args = {
    enable-crash-reporter = false;
    password-store = "gnome-libsecret";
  };

in
{
  # All the settings are managed by HM, which is a pain really.
  # vscode-fhs seems to alleviate that a bit; or just don't use the HM module
  # (and only the nix package).
  #
  # programs.vscode = {
  #   enable = true;
  #   enableUpdateCheck = false;
  #   userSettings = {
  #     "workbench.sideBar.location" = "right";
  #     "telemetry.telemetryLevel" = "off";
  #   };
  # };
  # home.packages = [ pkgs.vscode ];
  home.file.".vscode/argv.json".text = builtins.toJSON args;
}
