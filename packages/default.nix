self: super:
let
  inherit (super.pkgs) callPackage;

in
{
  local = {
    cti = callPackage ./cti.nix { };
  };
}
