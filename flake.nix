{
  description = "Home Manager configuration of mh";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      impermanence,
      nix-index-database,
    }:
    let
      # Commonly used variables
      system = "x86_64-linux";
      username = "mh";

      commonInsecurePackages = [ ];

      commonOverrides = final: prev: {
        # Disable unused features
        libinput = prev.libinput.override {
          wacomSupport = false;
        };
      };

      # Create an overlay that replaces the given package "pkg" with the version in "from"
      #
      # Usage example:
      #
      # pkgs = import nixpkgs {
      #   inherit system;
      #   overlays = [
      #     (replacePackage nixpkgs-brave "brave")
      #   ];
      # };
      _replacePackage =
        from: pkg:
        let
          pkgs-other = import from { inherit system; };
        in
        (final: prev: { "${pkg}" = pkgs-other."${pkg}"; });

      # Overwrite some settings for nixpkgs
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = commonInsecurePackages;

        overlays = [
          (import ./packages)
          commonOverrides
        ];
      };

      packages = pkgs.local;

      cudaPkgs = import nixpkgs {
        inherit system;
        config.cudaSupport = true;
        config.cudaCapabilities = [ "8.9" ];
        config.allowUnfree = true;
        overlays = [ commonOverrides ];
      };

      # specialArgs for NixOS
      specialArgs = {
        inherit username;
        secrets = import ./secrets.nix { lib = nixpkgs.lib; };
      };

      notebookSystem =
        hostModule:
        nixpkgs.lib.nixosSystem {
          inherit pkgs specialArgs system;

          modules = [
            impermanence.nixosModules.impermanence
            home-manager.nixosModules.home-manager
            nix-index-database.nixosModules.default
            hostModule
          ];
        };

    in
    {
      # nixosConfigurations for ... NixOS systems!
      # They also use home-manager, so those configs can be reused.
      nixosConfigurations = {
        nxzt = nixpkgs.lib.nixosSystem {
          inherit specialArgs system;
          pkgs = cudaPkgs;

          modules = [
            home-manager.nixosModules.home-manager
            nix-index-database.nixosModules.default
            ./hosts/nxzt
          ];
        };
        rotz = notebookSystem ./hosts/rotz;
      };

      packages."${system}" = packages;

      # Templatess to use with `nix flake init --template ...`
      templates = {
        default = {
          description = "A plain Nix Flake";
          path = ./templates/default;
        };
        bun = {
          description = "A template for Bun development";
          path = ./templates/bun;
        };
      };

      formatter."${system}" = pkgs.nixfmt;
    };
}
