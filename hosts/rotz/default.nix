{ pkgs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos
    ../../nixos/notebook.nix
    ../../nixos/persistence.nix
  ];
  home-manager.users.${username} = import ./home.nix;
  networking.hostName = "rotz";

  networking.wireguard.enable = true;
  environment.systemPackages = with pkgs; [
    cti
    wireguard-tools
  ];
  services.udev.packages = with pkgs; [ cti ];

  # TODO: Configure WirePlumber rules
  # - Disable internal devices
  # - Set priorities
  # See https://wiki.archlinux.org/title/WirePlumber and `services.pipewire.wireplumber.extraConfig`

  services.fwupd.enable = true;
  services.hardware.bolt.enable = true;

  # Printing
  services.printing = {
    enable = true;
    drivers = with pkgs; [ epson-escpr ];
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ username ];
  };
}
