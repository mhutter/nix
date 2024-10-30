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
    ./modules/ansible.nix
    ./modules/git.nix
    ./modules/go.nix
    ./modules/helix.nix
    ./modules/i3.nix
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

  programs.rbw = {
    enable = true;
    settings = secrets.rbw-settings // { pinentry = pkgs.pinentry-curses; };
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Applications
    morgen
    obsidian

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
    pwgen
    shellcheck
    uv
    yamllint
    yq-go

    # Kubernetes
    kind
    kubecolor
    kubectl
    kubelogin-oidc # kubectl oidc-login
    kubernetes-helm
    openshift # oc

    # Fonts
    font-awesome

    # See https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/data/fonts/nerdfonts/shas.nix
    (pkgs.nerdfonts.override {
      fonts = [
        "DejaVuSansMono"
        "FiraCode"
      ];
    })

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
  };

  home.sessionVariables = {
    BROWSER = "firefox";
  };
  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.local/bin"
  ];

  # After activation, report changes to the profile.
  home.activation.reportChanges = config.lib.dag.entryAnywhere ''
    run nix store diff-closures $oldGenPath $newGenPath
  '';

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
}
