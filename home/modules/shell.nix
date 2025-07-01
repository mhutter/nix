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
    initContent = ''
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

      # Pomodoro timer
      # Source: https://gist.github.com/bashbunni/3880e4194e3f800c4c494de286ebc1d7
      declare -A pomo_options
      pomo_options["work"]="25"
      pomo_options["break"]="5"

      pomodoro() {
        if [ -n "$1" -a -n "''${pomo_options["$1"]}" ]; then
        val=$1

        # Resize window to specific size
        i3-msg resize shrink width 10000px
        i3-msg resize grow width 160px
        i3-msg resize shrink height 10000px
        i3-msg resize grow height 13px

        # NOTE: Workaround until https://github.com/NixOS/nixpkgs/issues/400243 is resolved
        echo $val | ${pkgs.lolcat}/bin/lolcat 2>/dev/null
        ${pkgs.timer}/bin/timer ''${pomo_options["$val"]}m
        ${pkgs.libnotify}/bin/notify-send --app-name='Pomodoro' "$val session done"
        ${pkgs.speechd}/bin/spd-say "'$val' session done"
        fi
      }

      alias wo='pomodoro work'
      alias br='pomodoro break'

      argo-access() {
        kubectl -n argocd get secret/argocd-initial-admin-secret -o json | \
          jq -r '.data.password|@base64d' | \
          xclip

        xdg-open 'https://localhost:8443'
        kubectl -n argocd port-forward svc/argocd-server 8443:443
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
