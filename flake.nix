{
  description = "Home Manager configuration of mh";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        # config.permittedInsecurePackages = [ "..." ];
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
          "morgen"
          "obsidian"
        ];
      };
    in
    {
      homeConfigurations.mh = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./hosts/tera/home.nix ];
      };

      nixosConfigurations.nxzt = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ./hosts/nxzt/configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mh = import ./hosts/nxzt/home.nix;
          }
        ];
      };
    };
}
