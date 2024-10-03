{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    # Some packages that are required for the language servers
    extraPackages = with pkgs; [
      # Nix
      nil
      nixpkgs-fmt
      # TOML
      taplo
      # YAML
      yaml-language-server
    ];

    settings = {
      theme = "sonokai";
      editor = {
        bufferline = "always";
        file-picker.hidden = false;
        line-number = "relative";
        lsp = {
          display-messages = true;
          goto-reference-include-declaration = false;
          display-inlay-hints = true;
        };
        rulers = [ 80 ];
      };
      keys.normal = {
        "tab" = "goto_next_buffer";
        "S-tab" = "goto_previous_buffer";
      };
    };

    # See: https://github.com/helix-editor/helix/wiki/Language-Server-Configurations
    languages = {
      language-server = {
        rust-analyzer.config.check = { command = "clippy"; };
        yaml-language-server.config.yaml.schemas = {
          "https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json" = ".gitlab-ci*.{yml,yaml}";
          "https://json.schemastore.org/github-workflow.json" = ".github/workflows/*.{yml,yaml}";
          "https://json.schemastore.org/kustomization.json" = "kustomization.{yml,yaml}";
        };
      };

      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixpkgs-fmt";
        }
        {
          name = "toml";
          auto-format = true;
        }
      ];
    };

    ignores = [
      "target/"
      "node_modules/"
      ".git/"
    ];
  };
}
