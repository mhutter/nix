self: super: {
  cti = super.pkgs.callPackage ./cti.nix { };
  omnissa-horizon = super.pkgs.callPackage ./omnissa-horizon.nix { };
}
