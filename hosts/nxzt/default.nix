{ username, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos
  ];
  home-manager.users.${username} = import ./home.nix;

  networking.hostName = "nxzt";

  services.openssh = {
    enable = true;
    # Only reachable via the tailnet, which networking.firewall.trustedInterfaces
    # already covers. Set to true to also allow SSH from the local network.
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIENf5523OeX3ZEOJuAF9P5OLy+/S78UX7+xNC+O6AoD9 mh@rotz2026"
  ];

  # Graphics
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = false;
    open = true;
  };

  # AI
  # services.ollama = {
  #   enable = true;
  #   host = "100.112.141.2";
  # };
  # environment.variables = {
  #   OLLAMA_HOST = "100.112.141.2";
  # };

  # Gaming
  programs.steam.enable = true;
}
