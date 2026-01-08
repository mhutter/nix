{
  description = "Home Manager configuration of mh";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-citrix-workspace.url = "github:NixOS/nixpkgs/87894d3b7116a8e1c4827d66e17b89099d218c50";

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
      nixpkgs-citrix-workspace,
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
        "libxml2-2.13.8"
      ];

      # Overwrite some settings for nixpkgs
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = allowUnfree commonUnfreePackages;
        config.permittedInsecurePackages = commonInsecurePackages;
        overlays = [
          (import ./packages)
        ];
      };
      pkgs-citrix-workspace = import nixpkgs-citrix-workspace {
        inherit system;
        config.allowUnfreePredicate = allowUnfree [ "citrix-workspace" ];
        config.permittedInsecurePackages = [ "libsoup-2.74.3" ];
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
      };

      # specialArgs for NixOS
      specialArgs = {
        inherit username pkgs-citrix-workspace;
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

      formatter."${system}" = pkgs.nixfmt-rfc-style;
    };
}
