{ lib, username, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos
  ];

  networking.hostName = "tera";
  networking.hostId = "c989bdcb";

  fileSystems."/nix".neededForBoot = true;
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/log"
      { mode = "0600"; directory = "/var/lib/tailscale"; }
    ];
    files = [
      "/etc/machine-id"
      { parentDirectory = { mode = "0700"; }; file = "/etc/ssh/ssh_host_ed25519_key"; }
      { parentDirectory = { mode = "0700"; }; file = "/etc/ssh/ssh_host_rsa_key"; }
    ];

    users."${username}" = {
      directories = [
        "Downloads"
        "Sync"
        { mode = "0700"; directory = ".cache/BraveSoftware"; }
        { mode = "0700"; directory = ".config/BraveSoftware"; }
        { mode = "0700"; directory = ".config/nix"; }
        { mode = "0700"; directory = ".gnupg"; }
        { mode = "0700"; directory = ".ssh"; }
      ];
    };
  };

  # Graphics
  hardware.graphics.enable = true;
}
