{
  username,
  pkgs,
  secrets,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos
  ];
  home-manager.users.${username} = import ./home.nix;

  networking.hostName = "nxzt";

  # nxzt has no wired connectivity. Declare the wifi as a system-owned profile,
  # so the machine joins the network at boot instead of waiting for a login
  # session to hand NetworkManager the PSK from a keyring.
  networking.networkmanager.ensureProfiles.profiles.home = {
    connection = {
      id = "home";
      type = "wifi";
      autoconnect = true;
      permissions = ""; # usable by any user, not just the one who created it
    };
    wifi = {
      mode = "infrastructure";
      ssid = secrets.wifiHome.ssid;
    };
    wifi-security = {
      key-mgmt = "wpa-psk";
      psk = secrets.wifiHome.psk;
    };
    ipv4.method = "auto";
    ipv6.method = "auto";
  };

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
  hardware.nvidia-container-toolkit.enable = true;

  # Gaming
  programs.steam.enable = true;
}
