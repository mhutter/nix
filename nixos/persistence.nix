{ username, ... }:

{
  # Configure Impermanence
  fileSystems."/nix".neededForBoot = true;
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/AccountsService"
      "/var/lib/bluetooth"
      "/var/lib/boltd"
      "/var/lib/cups"
      "/var/lib/docker"
      "/var/lib/libvirt/"
      "/var/lib/nixos"
      "/var/lib/systemd/timers"
      "/var/log"
      {
        mode = "0700";
        directory = "/var/db/sudo/lectured";
      }
      {
        mode = "0700";
        directory = "/var/lib/tailscale";
      }
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
        ".cache/deno"
        ".cache/go-build"
        ".cache/helm"
        ".cache/nix"
        ".cache/nvim"
        ".cache/restic"
        ".cache/sccache"
        ".cache/spotify"
        ".cache/uv"
        ".cache/wasm-pack"
        ".cargo"
        ".config/1Password"
        ".config/BraveSoftware"
        ".config/CTI"
        ".config/autorandr"
        ".config/backrest"
        ".config/gcloud"
        ".config/gh"
        ".config/gtk-3.0"
        ".config/helm"
        ".config/kubeconfigs"
        ".config/nix"
        ".config/nvim"
        ".config/spotify"
        ".factorio"
        ".kube"
        ".local/share/Steam"
        ".local/share/atuin"
        ".local/share/backrest"
        ".local/share/direnv"
        ".local/share/helm"
        ".local/share/nvim"
        ".local/share/remmina"
        ".local/share/zoxide"
        ".local/state/nvim"
        ".local/state/syncthing"
        ".local/state/wireplumber"
        ".nx/config"
        ".omnissa"
        ".rustup"
        ".steam"
        "Brain"
        "Downloads"
        "Sync"
        "code"
        "go"
        "safe"
        {
          mode = "0700";
          directory = ".config/obsidian";
        }
        {
          mode = "0700";
          directory = ".config/op";
        }
        {
          mode = "0700";
          directory = ".config/remmina";
        }
        {
          mode = "0700";
          directory = ".gnupg";
        }
        {
          mode = "0700";
          directory = ".local/share/TelegramDesktop";
        }
        {
          mode = "0700";
          directory = ".local/share/keyrings";
        }
        {
          mode = "0700";
          directory = ".secrets";
        }
        {
          mode = "0700";
          directory = ".ssh";
        }
      ];
    };
  };
}
