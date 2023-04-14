{ pkgs, ... }:
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
      k = "kubectl";
      ka = "kubectl --as=cluster-admin";
      ks = "kubeseal --format yaml --cert";
      kubectl = "kubecolor";
      kubens = "kubectl config set-context --current --namespace";
      vim = "nvim"; # TODO: manage via package.nvim
    };

    dirHashes = {
      p = "$HOME/Projects";
      da = "$HOME/Projects/vshn/pacco/data";
      dev = "$HOME/dev";
    };

    initExtra = ''
      bindkey -e
      autoload -U select-word-style
      select-word-style bash

      # SSH-Agent
      if [[ -f /etc/arch-release ]]; then
        if ! pgrep -u "$USER" ssh-agent >/dev/null; then
          ssh-agent -t 12h > "$XDG_RUNTIME_DIR/ssh-agent.env"
        fi
        if [[ ! "$SSH_AGENT_SOCK" ]]; then
          source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
        fi
      fi
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
