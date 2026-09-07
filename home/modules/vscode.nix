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
    package =
      let
        # Patch broken syntax highlighting in current nixpkgs package
        vscode-fixed = pkgs.vscode.overrideAttrs (old: {
          postPatch = old.postPatch + ''
            ln -s node_modules resources/app/node_modules.asar.unpacked
          '';
        });
      in
      vscode-fixed;
  };

  home.file.".vscode/argv.json".text = builtins.toJSON args;
}
