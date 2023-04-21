{ pkgs, config, ... }:
{
  home.packages = [
    pkgs.zsh-completions
  ];

  programs.zsh = {
    enable = true;

    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
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

      # SSH-Agent
      if [[ -f /etc/arch-release ]]; then
        if ! pgrep -u "$USER" ssh-agent >/dev/null; then
          ssh-agent -t 12h > "$XDG_RUNTIME_DIR/ssh-agent.env"
        fi
        if [[ ! "$SSH_AGENT_SOCK" ]]; then
          source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
        fi
      fi

      temp() {
        local dir="$(date +%F)"
        if [ -n "$1" ]; then
          dir="$${dir}-$1"
        fi

        local p="$HOME/tmp/$dir"
        mkdir -p "$p"
        cd "$p"
      }
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

      time.disabled = false;

      aws.disabled = true;
      azure.disabled = true;
      gcloud.disabled = true;
    };
  };

  programs.bat.enable = true;
  programs.direnv.enable = true;
  programs.fzf.enable = true;
  programs.zoxide.enable = true;
}