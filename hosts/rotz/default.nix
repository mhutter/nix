{ pkgs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos
    ../../nixos/notebook.nix
    ../../nixos/persistence.nix
  ];
  home-manager.users.${username} = import ./home.nix;

  networking = {
    hostName = "rotz";
    wireguard.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Applications
    citrix_workspace_24_08_0
    nomachine-client
    openconnect
    remmina
    omnissa-horizon-client

    # CLI apps
    (google-cloud-sdk.withExtraComponents (
      with pkgs.google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]
    ))
    kubeconform
    mgitstatus

    # Utilities
    cifs-utils
    samba
    wireguard-tools

    # Custom packages
    cti
  ];
  services.udev.packages = with pkgs; [ cti ];

  # TODO: Configure WirePlumber rules
  # - Disable internal devices
  # - Set priorities
  # See https://wiki.archlinux.org/title/WirePlumber and `services.pipewire.wireplumber.extraConfig`

  services.fwupd.enable = true;
  services.hardware.bolt.enable = true;

  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    vpl-gpu-rt
  ];
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  # Virtualisation
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ username ];
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ username ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Printing
  services.printing = {
    enable = true;
    drivers = with pkgs; [ epson-escpr ];
  };

  # Samba share browsing
  services.gvfs.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ username ];
  };

  programs.steam.enable = true;
}
