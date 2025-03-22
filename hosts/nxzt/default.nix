{ username, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos
  ];
  home-manager.users.${username} = import ./home.nix;

  networking.hostName = "nxzt";

  # Graphics
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = false;
    open = true;
  };

  # AI
  services.ollama = {
    enable = true;
    host = "100.112.141.2";
  };
  environment.variables = {
    OLLAMA_HOST = "100.112.141.2";
  };

  # Gaming
  programs.steam = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [
    (lutris.override {
      extraLibraries = pkgs: [ ];
      extraPkgs = pkgs: [
        libnghttp2
        winetricks
      ];
    })
  ];
}
