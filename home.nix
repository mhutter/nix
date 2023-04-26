{ config, pkgs, ... }:

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

  imports = [
    ./modules/git.nix
    ./modules/rust.nix
    ./modules/shell.nix
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
    jq
    kubecolor
    kubectl
    ripgrep
    rnix-lsp
    tree
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

    (pkgs.writeShellScriptBin "ssh" ''
      TERM=xterm-256color /usr/bin/ssh -t $@ "tmux -2 new-session -A -s mh || bash"
    '')

    (pkgs.writeShellScriptBin "update-nix-stuff" ''
      set -e -u -o pipefail

      cd ~/.config/home-manager

      log() {
        echo -e "\033[2m[$(date +%T)]\033[0;33m $*\033[0m"
      }

      log "Updating nixpkgs"
      nix-channel --update

      log "Updating flakes"
      nix flake update
      
      if git diff --quiet flake.lock; then
        log "No changes to flake.lock"
      else
        log "flake.lock changed, committing"
        git add flake.lock
        git commit -m "Update system"
      fi 

      log "Switching to new home-manager configuration"
      home-manager switch

      log "Cleaning up old home-manager generations"
      home-manager expire-generations "-30 days"

      log "Cleaning up nix store"
      nix-collect-garbage --delete-older-than 30d
    '')
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
    "$HOME/.cargo/bin"
  ];
  home.sessionVariables = {
    EDITOR = "vim";
    BROWSER = "brave";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
