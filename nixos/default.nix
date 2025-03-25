{ pkgs, username, ... }:

let
  secrets = (import ../secrets.nix);

in
{
  imports = [
    ./modules/docker.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    windowManager.i3.enable = true;
    excludePackages = with pkgs; [
      xterm
    ];
    xkb.layout = "us";
  };
  services.displayManager.defaultSession = "none+i3";

  # Disable middle mouse button emulation when pressing left+right buttons simultaneously.
  services.libinput.mouse.middleEmulation = false;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  security.sudo.enable = false;
  security.sudo-rs.enable = true;

  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICl66G6py7JXAIqvcw0VW/Iqv1qmqWGRjjxTIzHOTUAg tera2025"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIERnSasc2L5AHp+uPCc+gCwF5HoPP5i2bnwwYycYfbpn mh@nxzt"
    ];
    initialHashedPassword = secrets.user.hashedPassword;
  };
  home-manager = {
    extraSpecialArgs = {
      inherit username;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  programs.zsh.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Applications
    alacritty
    brave
    firefox
    openmw
    telegram-desktop

    # CLI tools
    alsa-utils
    cachix
    curl
    gcc
    git
    vim
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-substituters = [ "https://mhu.cachix.org" ];
    trusted-public-keys = [ "mhu.cachix.org-1:GFzDWQDpycEzXVNVk/ROC/vMu2Wl6AYTzDuiUq85OB0=" ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # FIXME: Should not be enabled by default
  services.openssh.enable = true;

  # Enable Tailscale
  services.tailscale.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Make nixos-rebuild find its config automatically
  environment.etc."nixos".source = "/home/${username}/.config/nix";

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
