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

  programs.btop.settings.disks_filter = "/ /nix /boot";
}
