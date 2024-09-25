{ pkgs, lib, config, ... }:

let
  cfg = config.modules.git;
in
{
  options.modules.git = with lib; {
    userName = mkOption {
      description = "Name to be used for commit messages";
      type = types.str;
    };
    userEmail = mkOption {
      description = "Email to be used for commit messages";
      type = types.str;
    };
  };

  config = {
    home.packages = with pkgs; [ git-crypt ];

    programs.git = {
      enable = true;
      difftastic.enable = true;

      inherit (cfg) userName userEmail;
      signing.key = "3D7A6B26F12CD714";
      signing.signByDefault = true;

      extraConfig = {
        advice.forceDeleteBranch = true;
        color = {
          ui = "auto";
        };
        core = {
          autocrlf = "input";
          editor = "vim";
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
        ci = "commit -v -s";
        co = "checkout";
        st = "status";
        s = "status -s";
        ol = "log --oneline --graph";
        lg = "log --oneline --decorate --all --graph";
        hist = "log --graph --full-history --all --color --pretty=format:'%x1b[33m%h%x09%C(blue)(%ar)%C(reset)%x09%x1b[32m%d%x1b[0m%x20%s%x20%C(dim white)-%x20%an%C(reset)'";
        dc = "diff --check";
        tag-dates = "log --tags --simplify-by-decoration --pretty=\"format:%ai %d\"";
        log-sig = "log --pretty=\"format:%h %G? %aN %s\"";
        unstage = "reset HEAD";
        staged = "diff --staged";
        yolopush = "push --force-with-lease";
        fix = "commit --fixup";
        squ = "commit --squash";
        ri = "rebase -i --autosquash";
        pp = "pull --prune";
        brnach = "branch";
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
  };
}
