{ pkgs, mhutter, ... }:

let
  username = "mh";
  homeDirectory = "/home/${username}";
  secrets = (import ./secrets.nix);

in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = homeDirectory;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # TODO: icdiff
  imports = [
    ./modules/ansible.nix
    ./modules/backup.nix
    ./modules/git.nix
    ./modules/go.nix
    ./modules/rust.nix
    ./modules/shell.nix
    ./modules/ssh.nix
    ./modules/tmux.nix
    ./modules/vim.nix
    ./modules/vscode.nix
  ];

  modules.ssh.sshHosts = secrets.sshHosts;

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 43200;
    maxCacheTtl = 43200;
    pinentryFlavor = "tty";
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
    permittedInsecurePackages = [
      "electron-25.9.0"
    ];
  };

  programs.ripgrep.enable = true;

  programs.rbw = {
    enable = true;
    settings = secrets.rbw-settings // {
      pinentry = "tty";
    };
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = (with mhutter; [ ]) ++ (with pkgs; [
    # Applications
    arandr
    obsidian

    # CLI Tools
    btop
    dig
    fd
    github-cli
    go-jsonnet
    httpie
    jq
    just
    ncdu
    rnix-lsp
    sshuttle
    tree
    yamllint
    yq-go

    # Kubernetes
    kubecolor
    kubectl
    kubernetes-helm
    openshift # oc

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
    (pkgs.writeShellScriptBin "remove-known-host"
      (builtins.readFile (pkgs.substituteAll {
        src = ./bin/remove-known-host.sh;
        home = homeDirectory;
        grep = "${pkgs.gnugrep}/bin/grep";
        sed = "${pkgs.gnused}/bin/sed";
      })))

    (pkgs.writeShellScriptBin "argo-access"
      (builtins.readFile bin/argo-access.sh))

    (pkgs.writeShellScriptBin "socks-proxy"
      (builtins.readFile bin/socks-proxy.sh))

    (pkgs.writeShellScriptBin "update-mirrors"
      (builtins.readFile bin/update-mirrors.sh))

    (pkgs.writeShellScriptBin "update-nix-stuff"
      (builtins.readFile bin/update-nix-stuff.sh))

    (
      let
        name = "hotplug_monitor";
        # Joining paths in Nix is finnicky, so fuck around
        # see: https://gist.github.com/CMCDragonkai/de84aece83f8521d087416fa21e34df4
        src = ./bin + "/${name}.sh";
        # Create a package from our script
        script = (pkgs.writeScriptBin name (builtins.readFile src)).overrideAttrs (old: {
          # Patch shebang in our script
          buildCommand = "${old.buildCommand}\npatchShebangs $out";
        });
        deps = with pkgs;[
          dasel
          feh
          gawk
          gnugrep
          xorg.xrandr
        ];
      in
      # Ensure all dependencies are symlinked in place
      pkgs.symlinkJoin {
        inherit name;
        paths = [ script ] ++ deps;
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
      }
    )
  ]);

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
    BROWSER = "chromium";
  };
  home.sessionPath = [
    "$HOME/bin"
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
