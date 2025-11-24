{ pkgs, ... }:
{
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "battle.net" ''
      lutris lutris:rungame/battlenet
    '')
  ];
}
