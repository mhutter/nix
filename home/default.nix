# Common Home-Manager configuration that is valid for all systems/user

{ config, pkgs, username, ... }:

let
  homeDirectory = "/home/${username}";
  secrets = (import ../secrets.nix);

in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = homeDirectory;

  imports = [
    ./modules/alacritty.nix
    ./modules/ansible.nix
    ./modules/git.nix
    ./modules/go.nix
    ./modules/i3.nix
    ./modules/kubectl.nix
    ./modules/rust.nix
    ./modules/scripts.nix
    ./modules/shell.nix
    ./modules/ssh.nix
    ./modules/tmux.nix
    ./modules/vim.nix
    ./modules/vscode.nix
  ];

  modules.ssh.sshHosts = secrets.sshHosts;
  modules.git = {
    userName = secrets.user.name;
    userEmail = secrets.user.email;
  };

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 43200;
    maxCacheTtl = 43200;
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.ripgrep.enable = true;

  services.syncthing = {
    enable = true;
    overrideDevices = false;
    overrideFolders = false;
    settings.options.urAccepted = -1;
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Applications
    obsidian
    spotify

    # CLI Tools
    btop
    dig
    dive
    entr
    fd
    github-cli
    go-jsonnet
    httpie
    jq
    just
    ncdu
    nodePackages.prettier
    pwgen
    shellcheck
    unzip
    uv
    yamllint
    yq-go

    # Fonts
    font-awesome
    nerd-fonts.fira-code
    nerd-fonts.dejavu-sans-mono

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Ensure NixOS can pick up fonts installed by HM
  fonts.fontconfig.enable = true;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".config/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme = true
    '';
    ".config/gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme = true
    '';
  };

  home.sessionVariables = {
    BROWSER = "brave";
  };
  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.local/bin"
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
}
