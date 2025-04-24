self: super: {
  cti = super.pkgs.callPackage ./cti.nix { };
  omnissa-horizon-client = super.pkgs.callPackage ./omnissa-horizon-client.nix { };
}
