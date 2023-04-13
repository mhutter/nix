{ ... }:
{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;

    autocd = true;
    dirHashes = {
      p = "$HOME/Projects";
      da = "$HOME/Projects/vshn/pacco/data";
      dev = "$HOME/dev";
    };
  };

  programs.bat.enable = true;

  programs.direnv = {
    enable = true;
    # check whether nix-direnv is an option?
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
    enableZshIntegration = true;
    settings = {
      add_newline = true;

      aws.disabled = true;
      azure.disabled = true;
      gcloud.disabled = true;
    };
  };
}
