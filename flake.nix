{
  description = "Home Manager configuration of mh";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-mh.url = "github:mhutter/nixpkgs/i3status-notmuch";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-mh, home-manager }:
    let
      # Commonly used variables
      system = "x86_64-linux";
      username = "mh";

      commonUnfreePackages = [
        # Applications
        "morgen"
        "obsidian"
        "steam"
        "steam-original"
        "steam-unwrapped"
        "steam-run"
        "vscode"
      ];

      # Overwrite some settings for nixpkgs
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) commonUnfreePackages;
      };
      pkgs-mh = import nixpkgs-mh { inherit system; };

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

      # extraArgs for home-manager
      extraSpecialArgs = { inherit username pkgs-mh; };

    in
    {
      # homeConfigurations for systems that use home-manager directly and are
      # no NixOS systems (e.g. my Arch notebook)
      homeConfigurations.mh = home-manager.lib.homeManagerConfiguration {
        # Use extraSpecialArgs and customized pkgs
        inherit extraSpecialArgs pkgs;

        modules = [ ./hosts/tera/home.nix ];
      };

      # nixosConfigurations for ... NixOS systems!
      # They also use home-manager, so those configs can be reused.
      nixosConfigurations.nxzt = nixpkgs.lib.nixosSystem {
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

      # Templatess to use with `nix flake init --template ...`
      templates = {
        default = {
          description = "A plain Nix Flake";
          path = ./templates/default;
        };
      };
    };
}
