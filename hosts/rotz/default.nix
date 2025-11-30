{
  pkgs,
  pkgs-citrix-workspace,
  username,
  secrets,
  ...
}:

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
    wireguard.interfaces.wg0 =
      let
        wgdir = "/nix/persist/var/lib/wireguard";
      in
      {
        privateKeyFile = "${wgdir}/private";
        ips = [ "10.13.37.10/24" ];
        peers = [
          {
            name = "bastion";
            allowedIPs = [ "10.13.37.0/24" ];
            presharedKeyFile = "${wgdir}/presharedkey";
            inherit (secrets.wg) endpoint publicKey;
          }
        ];
      };
  };

  environment.systemPackages = with pkgs; [
    # Applications
    pkgs-citrix-workspace.citrix_workspace
    omnissa-horizon-client

    # CLI apps
    (google-cloud-sdk.withExtraComponents (
      with pkgs.google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]
    ))
    cookiecutter
    cruft
    gemini-cli
    glab
    gnumake
    kubeconform
    kubeseal
    mgitstatus

    # Utilities
    cifs-utils
    samba
    wireguard-tools

    # Custom packages
    local.cti
  ];
  services.udev.packages = [ pkgs.local.cti ];

  # TODO: Configure WirePlumber rules
  # - Disable internal devices
  # - Set priorities
  # See https://wiki.archlinux.org/title/WirePlumber and `services.pipewire.wireplumber.extraConfig`

  services.hardware.bolt.enable = true;

  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    vpl-gpu-rt
  ];
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  # Virtualisation
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu = {
    # virtiofsd driver to mount host directories into the guest
    vhostUserPackages = [ pkgs.virtiofsd ];
  };
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;
  # Allow user to manage VMs
  users.extraGroups.vboxusers.members = [ username ];
  users.groups.libvirtd.members = [ username ];

  # Enable the common /etc/containers configuration module
  virtualisation.containers.enable = true;

  # Printing
  services.printing = {
    enable = true;
    drivers = with pkgs; [ epson-escpr ];
  };

  # Samba share browsing
  services.gvfs.enable = true;

  # Languagetool
  services.languagetool.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ username ];
  };
}
