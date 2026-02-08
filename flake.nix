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
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      impermanence,
    }:
    let
      # Commonly used variables
      system = "x86_64-linux";
      username = "mh";

      commonUnfreePackages = [
        # Applications
        "1password"
        "1password-cli"
        "citrix-workspace"
        "code"
        "nomachine-client"
        "obsidian"
        "omnissa-horizon-client"
        "spotify"
        "steam"
        "steam-original"
        "steam-run"
        "steam-unwrapped"
        "vscode"
      ];
      allowUnfree = allowed: pkg: builtins.elem (nixpkgs.lib.getName pkg) allowed;
      commonInsecurePackages = [
        "libsoup-2.74.3"
      ];

      commonOverrides = final: prev: {
        libinput = prev.libinput.override {
          wacomSupport = false;
        };
      };

      # Overwrite some settings for nixpkgs
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = allowUnfree commonUnfreePackages;
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
        inherit username;
        secrets = import ./secrets.nix;
      };

      notebookSystem =
        hostModule:
        nixpkgs.lib.nixosSystem {
          inherit pkgs specialArgs system;

          modules = [
            impermanence.nixosModules.impermanence
            home-manager.nixosModules.home-manager
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
      };

      formatter."${system}" = pkgs.nixfmt;
    };
}
