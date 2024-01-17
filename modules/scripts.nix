{ pkgs, config, ... }:
let
  scriptWithDeps = name: deps:
    let
      # Joining paths in Nix is finnicky, so fuck around
      # see: https://gist.github.com/CMCDragonkai/de84aece83f8521d087416fa21e34df4
      src = ../bin + "/${name}.sh";
      # Create a package from our script
      script = (pkgs.writeScriptBin name (builtins.readFile src)).overrideAttrs (old: {
        # Patch shebang in our script
        buildCommand = "${old.buildCommand}\npatchShebangs $out";
      });
    in
    # Ensure all dependencies are symlinked in place
    pkgs.symlinkJoin {
      inherit name;
      paths = [ script ] ++ deps;
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
    };

in
with pkgs;
{
  home.packages = [
    (scriptWithDeps "argo-access" [ kubectl xclip xdg-utils ])
    (scriptWithDeps "hotplug_monitor" [ dasel feh gawk gnugrep xorg.xrandr ])
    (scriptWithDeps "remove-known-host" [ gnugrep gnused ])
    (scriptWithDeps "socks-proxy" [ openssh ])
    (scriptWithDeps "update-mirrors" [ ]) # technically needs update-mirrors but that is specific to Arch
    (scriptWithDeps "update-nix-stuff" [ ]) # nix and home-manager are already present
  ];
}
