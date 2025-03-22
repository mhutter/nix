{ config, username, ... }:

let
  homeDir = config.users.users.${username}.home;
  configDir = ".config/nix";
  configPath = "${homeDir}/${configDir}";

in
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos
    ../../nixos/notebook.nix
  ];

  networking.hostName = "tera";

  # Configure Impermanence
  fileSystems."/nix".neededForBoot = true;
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
      "/var/lib/docker"
      "/var/lib/nixos"
      "/var/log"
      { mode = "0700"; directory = "/var/db/sudo/lectured"; }
      { mode = "0700"; directory = "/var/lib/tailscale"; }
    ];
    files = [
      "/etc/machine-id"
      # Some of the config must be readable by others so the parent dir cannot be 0700
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key"
    ];

    users."${username}" = {
      directories = [
        ".cache/BraveSoftware"
        ".cache/nvim"
        ".cache/sccache"
        ".cargo"
        ".config/BraveSoftware"
        ".config/nvim"
        ".local/share/atuin"
        ".local/share/nvim"
        ".local/share/zoxide"
        ".local/state/nvim"
        ".local/state/syncthing"
        ".rustup"
        "Downloads"
        "Sync"
        "code"
        "go"
        "safe"
        configDir
        { mode = "0700"; directory = ".gnupg"; }
        { mode = "0700"; directory = ".ssh"; }
      ];
      files = [
        ".zsh_history"
      ];
    };
  };

  # Graphics
  hardware.graphics.enable = true;

  # Link NixOS configuration
  environment.etc."nixos".source = configPath;
}
