{ pkgs, ... }:

let
  username = "mh";
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "22.11"; # Please read the comment before changing.

  # TODO: Ansible
  # TODO: Languagetool
  # TODO: Provider CLIs: aws, azure, exoscale, hcloud
  imports = [
    ./modules/backup.nix
    ./modules/helix.nix
    ./modules/git.nix
    ./modules/rust.nix
    ./modules/shell.nix
    ./modules/ssh.nix
  ];

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 43200;
    maxCacheTtl = 43200;
    pinentryFlavor = "tty";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    btop
    fd
    github-cli
    go-jsonnet
    httpie
    jq
    just
    kubecolor
    kubectl
    ripgrep
    rnix-lsp
    tree
    yamllint
    yq

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    (pkgs.writeShellScriptBin "update-nix-stuff"
      (builtins.readFile bin/update-nix-stuff.sh))
  ];

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
  };

  home.sessionPath = [
    "$HOME/bin"
  ];
  home.sessionVariables = {
    EDITOR = "vim";
    BROWSER = "brave";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
