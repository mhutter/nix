{
  description = "Home Manager configuration of mh";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, home-manager, impermanence }:
    let
      # Commonly used variables
      system = "x86_64-linux";
      username = "mh";

      # extraArgs for home-manager
      extraSpecialArgs = { inherit username; };

      commonUnfreePackages = [
        # Applications
        "obsidian"
        "spotify"
        "steam"
        "steam-original"
        "steam-run"
        "steam-unwrapped"
        "vscode"
      ];

      # Overwrite some settings for nixpkgs
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) commonUnfreePackages;
      };

      cudaPkgs = import nixpkgs {
        inherit system;
        config.cudaSupport = true;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) (commonUnfreePackages ++ [
          "blender"
          "cuda_cudart"
          "cuda_nvcc"
          "cuda_cccl"
          "libcublas"
          "nvidia-x11"
        ]);
      };

    in
    {
      # homeConfigurations for systems that use home-manager directly and are
      # no NixOS systems (e.g. my Arch notebook)
      homeConfigurations."mh@tera" = home-manager.lib.homeManagerConfiguration {
        # Use extraSpecialArgs and customized pkgs
        inherit extraSpecialArgs pkgs;

        modules = [ ./hosts/tera/home.nix ];
      };

      # nixosConfigurations for ... NixOS systems!
      # They also use home-manager, so those configs can be reused.
      nixosConfigurations = {
        nxzt = nixpkgs.lib.nixosSystem {
          inherit system;
          pkgs = cudaPkgs;

          modules = [
            # Pass username to modules
            ({ ... }: { config._module.args = { inherit username; }; })

            # host-specific configuration
            ./hosts/nxzt

            # Include home-manager
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                inherit extraSpecialArgs;
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import ./hosts/nxzt/home.nix;
              };
            }
          ];
        };
        tera = nixpkgs.lib.nixosSystem {
          inherit pkgs system;

          modules = [
            # Pass username to modules
            ({ ... }: { config._module.args = { inherit username; }; })

            # Impermanence
            impermanence.nixosModules.impermanence

            # host-specific configuration
            ./hosts/tera

            # Include home-manager
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                inherit extraSpecialArgs;
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import ./hosts/tera/home.nix;
              };
            }
          ];
        };
      };

      # Templatess to use with `nix flake init --template ...`
      templates = {
        default = {
          description = "A plain Nix Flake";
          path = ./templates/default;
        };
      };
    };
}
