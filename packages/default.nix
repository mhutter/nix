self: super:
let
  inherit (super.pkgs) callPackage;

in
{
  local = (callPackage ./brave { }) // {
    claude-desktop = callPackage ./claude-desktop.nix { };
    cti = callPackage ./cti.nix { };
    drydock = callPackage ./drydock.nix { };
    ink-md = callPackage ./ink-md.nix { };
  };
}
