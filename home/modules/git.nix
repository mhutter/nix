{
  pkgs,
  lib,
  secrets,
  ...
}:

{
  home.packages = with pkgs; [ git-crypt ];

  programs.git = {
    enable = true;
    difftastic.enable = true;

    userName = secrets.user.name;
    userEmail = secrets.user.email;
    signing.key = "FC31B4E54C4CF892";
    signing.signByDefault = true;

    includes = [
      {
        condition = "gitdir:**/riag/**/.git";
        contents = {
          user = {
            email = secrets.user.workEmail;
            signingKey = "CCE9BDBE1A068B95";
          };
        };
      }
    ];

    extraConfig = {
      advice.forceDeleteBranch = true;
      color = {
        ui = "auto";
      };
      core = {
        autocrlf = "input";
        # editor = "vim";
        sshCommand = "${pkgs.openssh}/bin/ssh";
      };
      diff.sopsdiffer.textconv = "sops -d";
      init.defaultBranch = "main";
      pull.rebase = true;
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      rebase.autoStash = true;
      rerere.enabled = 1;
    };

    aliases = {
      brnach = "branch";
      ci = "commit -v -s";
      co = "checkout";
      dc = "diff --check";
      fix = "commit --fixup";
      hist = "log --graph --full-history --all --color --pretty=format:'%x1b[33m%h%x09%C(blue)(%ar)%C(reset)%x09%x1b[32m%d%x1b[0m%x20%s%x20%C(dim white)-%x20%an%C(reset)'";
      lg = "log --oneline --decorate --all --graph";
      log-sig = "log --pretty=\"format:%h %G? %aN %s\"";
      ol = "log --oneline --graph";
      pp = "pull --prune";
      ri = "rebase -i --autosquash";
      s = "status -s";
      squ = "commit --squash";
      st = "status";
      staged = "diff --staged";
      tag-dates = "log --tags --simplify-by-decoration --pretty=\"format:%ai %d\"";
      unstage = "reset HEAD";
      yolopush = "push --force-with-lease";
    };

    ignores = [
      # from https://help.github.com/articles/ignoring-files
      # Compiled source #
      ###################
      "*.class"
      "*.dll"
      "*.exe"
      "*.o"
      "*.so"
      "gin-bin"

      # Packages #
      ############
      # it's better to unpack these files and commit the raw source
      # git has its own built in compression methods
      "*.7z"
      "*.dmg"
      "*.gz"
      "*.iso"
      "*.jar"
      "*.rar"
      "*.tar"
      "*.zip"

      # Logs and databases #
      ######################
      "*.log"
      "*.sqlite"
      "*.dump"

      # OS generated files #
      ######################
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "Icon?"
      "ehthumbs.db"
      "Thumbs.db"
      ".*~"
      "*.swp"
      ".issues-cache"
      ".bundle"
      "node_modules/"
      ".netrwhist"
      "*.bak"
      "tmp/"
      ".vscode/"
      "*.patch"
      ".envrc"
      ".env"
      ".direnv/"
      ".kubeconfig"
      "id_rsa"
    ];
  };
}
