{ pkgs, config, ... }:
let
  fortune = pkgs.fortune;
  cookies = "~/Dropbox/Obsidian/VSHN/Fortunes.md";

in
{
  home.packages = [
    pkgs.zsh-completions
  ];

  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autocd = true;

    shellAliases = {
      cat = "bat";
      catp = "bat -p";
      t = "tmux new-session -A -s";
    };

    dirHashes = {
      p = "$HOME/Projects";
      da = "$HOME/Projects/vshn/pacco/data";
      dev = "$HOME/dev";
    };

    # Note: In multiline strings, the $ sign can be escaped by prefixing
    # it with `''`
    initExtra = ''
      # more bash-like keybinds (^W etc)
      bindkey -e
      bindkey "^[[3~" delete-char

      # more bash-like word boundaries
      autoload -U select-word-style
      select-word-style bash

      # Add go bin to path
      which go &>/dev/null && export PATH="$(go env GOPATH)/bin:$PATH"

      temp() {
        local dir="$(date +%F)"
        if [ -n "$1" ]; then
          dir="''${dir}-$1"
        fi

        local p="$HOME/tmp/$dir"
        mkdir -p "$p"
        cd "$p"
      }

      x() {
        z $@
        tmux new-session -A -s "$1"
      }

      ${fortune}/bin/strfile -c '%' -s ${cookies} ${cookies}.dat
      ${fortune}/bin/fortune ${cookies}
    '';
  };

  programs.atuin = {
    enable = true;
    settings = {
      # style
      style = "compact";
      inline_height = 10;

      # features
      enter_accept = true;

      # stats
      stats.common_subcommands = [
        "k"
        "kubecolor"
        "oc"
        "t"
        "z"
        # upstream defaults
        "cargo"
        "go"
        "git"
        "npm"
        "yarn"
        "pnpm"
        "kubectl"
      ];
    };
  };

  programs.eza = {
    enable = true;
    extraOptions = [
      "--group-directories-first"
    ];
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;

      character.success_symbol = "[C:\\\\>](bold green)";
      character.error_symbol = "[C:\\\\>](bold red)";

      aws.disabled = true;
      azure.disabled = true;
      gcloud.disabled = true;
    };
  };

  programs.bat = {
    enable = true;
    config.map-syntax = [
      "*.bu:YAML"
      "*.ign:JSON"
    ];
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.fzf.enable = true;
  programs.zoxide.enable = true;
}
