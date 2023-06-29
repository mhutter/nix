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

    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autocd = true;

    shellAliases = {
      cat = "bat";
      catp = "bat -p";
      k = "kubecolor";
      ka = "k --as=cluster-admin";
      ks = "kubeseal --format yaml --cert";
      kubens = "k config set-context --current --namespace";
      vim = "nvim"; # TODO: manage via package.nvim
    };

    dirHashes = {
      p = "$HOME/Projects";
      da = "$HOME/Projects/vshn/pacco/data";
      dev = "$HOME/dev";
    };

    initExtra = ''
      # more bash-like keybinds (^W etc)
      bindkey -e
      bindkey "^[[3~" delete-char

      # more bash-like word boundaries
      autoload -U select-word-style
      select-word-style bash

      # Fix completions for kubecolor aliases
      compdef kubecolor=kubectl

      # Add go bin to path
      which go &>/dev/null && export PATH="$(go env GOPATH)/bin:$PATH"

      # Add `cluster` command
      cluster() { cp ~/.config/cattledog/kubeconfigs/"$1" ~/.kube/config }
      _cluster() { _files -W ~/.config/cattledog/kubeconfigs -/; }
      compdef _cluster cluster

      temp() {
        local dir="$(date +%F)"
        if [ -n "$1" ]; then
          dir="$${dir}-$1"
        fi

        local p="$HOME/tmp/$dir"
        mkdir -p "$p"
        cd "$p"
      }

      ${fortune}/bin/strfile -c '%' -s ${cookies} ${cookies}.dat
      ${fortune}/bin/fortune ${cookies}
    '';
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
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

  programs.bat.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.fzf.enable = true;
  programs.zoxide.enable = true;
}
