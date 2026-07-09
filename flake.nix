{
  description = "Home Manager configuration of mh";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-brave.url = "github:NixOS/nixpkgs/278f591c82199a7bd7225da86bed46c3728b4be2";
    nixpkgs-citrix-workspace.url = "github:mhutter/nixpkgs/citrix-workspace-26.04.0.105";

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
      nixpkgs-brave,
      nixpkgs-citrix-workspace,
      home-manager,
      impermanence,
      nix-index-database,
    }:
    let
      # Commonly used variables
      system = "x86_64-linux";
      username = "mh";

      commonUnfreePackages = [
        "1password"
        "1password-cli"
        "citrix-workspace"
        "claude-code"
        "code"
        "linuxx64" # dep of citrix-workspace
        "nomachine-client"
        "obsidian"
        "omnissa-horizon-client"
        "spotify"
        "steam"
        "steam-original"
        "steam-run"
        "steam-unwrapped"
        "vscode"
        "webex"
      ];
      allowUnfree = allowed: pkg: builtins.elem (nixpkgs.lib.getName pkg) allowed;
      commonInsecurePackages = [ ];

      commonOverrides = final: prev: {
        # Disable unused features
        libinput = prev.libinput.override {
          wacomSupport = false;
        };

        # Disable broken tests for openldap
        # see: https://github.com/NixOS/nixpkgs/issues/514113
        openldap = prev.openldap.overrideAttrs (old: {
          doCheck = false;
        });
      };

      pkgs-brave = import nixpkgs-brave { inherit system; };

      # Overwrite some settings for nixpkgs
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = allowUnfree commonUnfreePackages;
        config.permittedInsecurePackages = commonInsecurePackages;

        overlays = [
          (import ./packages)
          commonOverrides
          (final: prev: { brave = pkgs-brave.brave; })
        ];
      };

      citrixPkgs = import nixpkgs-citrix-workspace {
        inherit system;
        config.allowUnfreePredicate = allowUnfree commonUnfreePackages;
        config.permittedInsecurePackages = commonInsecurePackages;

        overlays = [
          commonOverrides
        ];
      };

      packages = pkgs.local;

      cudaPkgs = import nixpkgs {
        inherit system;
        config.cudaSupport = true;
        cudaCapabilities = [ "8.9" ];
        config.allowUnfreePredicate = allowUnfree (
          commonUnfreePackages
          ++ [
            "cuda_cccl"
            "cuda_cudart"
            "cuda_nvcc"
            "cuda_nvrtc"
            "cudnn"
            "libcublas"
            "libcufft"
            "libcurand"
            "libcusparse"
            "libnvjitlink"
            "nvidia-x11"
          ]
        );
        overlays = [ commonOverrides ];
      };

      # specialArgs for NixOS
      specialArgs = {
        inherit username citrixPkgs;
        secrets = import ./secrets.nix;
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
