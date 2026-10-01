{
  username,
  pkgs,
  secrets,
  ...
}:
let
  # aiohttp-client-cache 0.14.3 tests fail with aiohttp >= 3.14 and pytest >= 9.1.
  # Both are fixed upstream, but unreleased. Drop once nixpkgs ships a newer version.
  python3 = pkgs.python3.override {
    self = python3;
    packageOverrides = pyfinal: pyprev: {
      aiohttp-client-cache = pyprev.aiohttp-client-cache.overridePythonAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (pkgs.fetchpatch {
            url = "https://github.com/requests-cache/aiohttp-client-cache/commit/6fdc8b3f4ed318f0a0b42f8906884b99e7a70d38.patch";
            hash = "sha256-9WMLLDWvU4tlpeO+1IAxwtmkj8eoMMqCUomk6mxm9Ks=";
          })
          (pkgs.fetchpatch {
            url = "https://github.com/requests-cache/aiohttp-client-cache/commit/db7910effe01650a0ca16af0f528ca01445bebcf.patch";
            hash = "sha256-YEeiO4h7YySlTE+lqL0tS6l9hmzOnsQAl5uqP3nNGA8=";
          })
        ];
      });
    };
  };
  instawow = pkgs.instawow.override { inherit python3; };
in
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
  environment.systemPackages = [ instawow ];
}
