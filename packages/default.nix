self: super:
let
  callPackage = super.pkgs.callPackage;
in
{
  local = {
    cti = callPackage ./cti.nix { };
    omnissa-horizon-client = callPackage ./omnissa-horizon-client.nix { };
  };
}
