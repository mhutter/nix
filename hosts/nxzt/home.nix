{ pkgs, ... }:
{
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [
    # blender
    (pkgs.writeShellScriptBin "battle.net" ''
      lutris lutris:rungame/battlenet
    '')
  ];
}
