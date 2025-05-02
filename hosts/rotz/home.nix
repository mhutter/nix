{ ... }:

{
  imports = [
    ../../home
    # ../../home/modules/backup.nix
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  programs = {
    btop.settings.disks_filter = "/ /nix /boot";
    zsh.history.path = "/nix/persist/home/mh/.zsh_history";
  };
}
