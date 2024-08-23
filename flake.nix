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

  outputs = inputs @ { self, nixpkgs, home-manager }:
    let
      system = "x86_64-linux";
      username = "mh";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
          "morgen"
          "obsidian"
        ];
      };

      extraSpecialArgs = inputs // { inherit username; };
    in
    {
      homeConfigurations.mh = home-manager.lib.homeManagerConfiguration {
        inherit extraSpecialArgs pkgs;

        modules = [ ./hosts/tera/home.nix ];
      };

      nixosConfigurations.nxzt = nixpkgs.lib.nixosSystem {
        inherit pkgs system;

        modules = [
          ./hosts/nxzt

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              inherit extraSpecialArgs;
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import./hosts/nxzt/home.nix;
            };
          }
        ];
      };
    };
}
