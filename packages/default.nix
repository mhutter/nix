self: super:
let
  inherit (super.pkgs) callPackage;

in
{
  local = {
    claude-desktop = callPackage ./claude-desktop.nix { };
    cti = callPackage ./cti.nix { };
    drydock = callPackage ./drydock.nix { };
  };
}
