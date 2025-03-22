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
  home-manager.users.${username} = import ./home.nix;

  networking.hostName = "tera";

  # TODO: Configure WirePlumber rules
  # - Disable internal devices
  # - Set priorities
  # See https://wiki.archlinux.org/title/WirePlumber and `services.pipewire.wireplumber.extraConfig`

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

    # While this may be better off in the home-manager config with their
    # respective modules; the NixOS module implementation seems much more
    # powerful and straight-forward to use. So I'll bite the bullet and manage
    # it all here.
    users."${username}" = {
      directories = [
        ".cache/BraveSoftware"
        ".cache/nix"
        ".cache/nvim"
        ".cache/sccache"
        ".cache/spotify"
        ".cargo"
        ".config/BraveSoftware"
        ".config/autorandr"
        ".config/gh"
        ".config/nvim"
        ".config/spotify"
        ".local/share/atuin"
        ".local/share/direnv"
        ".local/share/nvim"
        ".local/share/zoxide"
        ".local/state/nvim"
        ".local/state/syncthing"
        ".local/state/wireplumber"
        ".rustup"
        "Downloads"
        "Sync"
        "code"
        "go"
        "safe"
        configDir
        { mode = "0700"; directory = ".config/obsidian"; }
        { mode = "0700"; directory = ".gnupg"; }
        { mode = "0700"; directory = ".local/share/TelegramDesktop"; }
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
