{
  pkgs,
  username,
  secrets,
  ...
}:

let
  gcloud-cli = (
    pkgs.google-cloud-sdk.withExtraComponents (
      with pkgs.google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]
    )
  );
in
{
  imports = [
    ./hardware-configuration.nix
    ./wireguard.nix
    ../../nixos
    ../../nixos/notebook.nix
    ../../nixos/persistence.nix
  ];
  home-manager.users.${username} = import ./home.nix;

  networking = {
    hostName = "rotz";
    hosts =
      let
        blockedHosts = [
          # Facebook trackers
          "www.facebook.com"
          "connect.facebook.net"
        ];
      in
      secrets.extraHosts
      // {
        "0.0.0.0" = blockedHosts;
        "::" = blockedHosts;
      };
  };

  environment.systemPackages = with pkgs; [
    # Applications
    citrix-workspace
    firefox
    omnissa-horizon-client
    remmina
    webex

    # CLI apps
    age
    ansible
    cookiecutter
    cruft
    gcloud-cli
    glab
    gnumake
    kubeseal
    proton-vpn-cli
    skopeo
    sqlx-cli
    trivy

    # Utilities
    cifs-utils
    pulseaudio # only for the client tools (pactl, used by i3 volume keys)
    samba
    whois
    wireguard-tools

    # Custom packages
    local.claude-desktop
    local.cti
    local.drydock
    local.ink-md
  ];
  services.udev.packages = [ pkgs.local.cti ];
  systemd.tmpfiles.rules = [
    # pbxcti hardcodes /opt/pbxcti paths (ring sounds etc.)
    "L+ /opt/pbxcti - - - - ${pkgs.local.cti}/opt/pbxcti"
    # Claude Desktop's Cowork VM looks for UEFI firmware at a hardcoded path
    "L+ /usr/share/OVMF - - - - ${pkgs.OVMF.fd}/FV"
  ];

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

  ### Virtualisation - libvirtd
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu = {
    package = pkgs.qemu_kvm;
    # virtiofsd driver to mount host directories into the guest
    vhostUserPackages = [ pkgs.virtiofsd ];
    # Enable TPM emulation (for windows guests)
    swtpm.enable = true;
  };
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;
  # Allow user to manage VMs
  users.extraGroups.vboxusers.members = [ username ];
  users.groups.libvirtd.members = [ username ];

  ## Virtualisation - VirtualBox
  virtualisation.virtualbox.host.enable = true;

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
    # Fix SIGTRAP on launch
    # https://github.com/NixOS/nixpkgs/issues/576668
    # source: https://github.com/NixOS/nixpkgs/pull/576689#issuecomment-6403331077
    # Fix PR: https://github.com/NixOS/nixpkgs/pull/579025
    package = pkgs._1password-gui.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        patchelf \
          --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "$(patchelf --print-rpath $out/share/1password/1password)" \
          $out/share/1password/chrome_crashpad_handler
      '';
    });
  };
}
