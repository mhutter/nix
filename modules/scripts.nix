{ pkgs, config, ... }:
let
  scriptWithDeps = (name: deps:
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
    }
  );
in
with pkgs;
{
  home.packages = [
    (pkgs.writeShellScriptBin "remove-known-host"
      (builtins.readFile (pkgs.substituteAll {
        src = ../bin/remove-known-host.sh;
        home = config.home.homeDirectory;
        grep = "${pkgs.gnugrep}/bin/grep";
        sed = "${pkgs.gnused}/bin/sed";
      })))

    (pkgs.writeShellScriptBin "argo-access"
      (builtins.readFile ../bin/argo-access.sh))

    (pkgs.writeShellScriptBin "socks-proxy"
      (builtins.readFile ../bin/socks-proxy.sh))

    (pkgs.writeShellScriptBin "update-mirrors"
      (builtins.readFile ../bin/update-mirrors.sh))

    (pkgs.writeShellScriptBin "update-nix-stuff"
      (builtins.readFile ../bin/update-nix-stuff.sh))

    (scriptWithDeps "hotplug_monitor" [ dasel feh gawk gnugrep xorg.xrandr ])
  ];
}
