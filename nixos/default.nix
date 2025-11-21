{
  config,
  lib,
  pkgs,
  secrets,
  username,
  ...
}:

let
  homeDir = config.users.users.${username}.home;
  configDir = ".config/nix";
  configPath = "${homeDir}/${configDir}";
  rhea = secrets.sshHosts.rhea;

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

  # Workaroud for Shokz sending shutdown signals
  services.logind.settings.Login.HandlePowerKey = "ignore";

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # Graphics
  hardware.graphics.enable = true;

  security.sudo.enable = false;
  security.sudo-rs = {
    enable = true;
    # Some helpers (like switching power modes) require `sudo` but cannot
    # prompt for a password.
    wheelNeedsPassword = false;
  };

  security.pki.certificates = secrets.customCACertificates;
  # Ensure i3lock can unlock the system again
  # c.f. https://github.com/NixOS/nixpkgs/issues/401891
  security.pam.services.i3lock.enable = true;

  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "networkmanager" # Allow management of network settings
    ];
    shell = pkgs.zsh;
    initialHashedPassword = secrets.user.hashedPassword;
  };
  home-manager = {
    extraSpecialArgs = {
      inherit username secrets;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  programs.zsh.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Bare minimum
    git
    vim

    # Applications
    alacritty
    brave
    telegram-desktop
    vlc
    xfce.thunar

    # CLI tools
    alsa-utils
    xclip
  ];

  programs.nh = {
    enable = true;
    flake = "~/.config/nix";
  };

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ username ];
    substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-substituters = [
      "ssh://nix-ssh@${rhea.hostname}:${builtins.toString rhea.port}"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Some stuff required for desktop environments
  services.gnome.gnome-keyring.enable = true;
  programs.dconf.enable = true;

  # Disable unused features
  services.speechd.enable = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Link NixOS configuration
  environment.etc."nixos".source = configPath;

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
