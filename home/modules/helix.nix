{ lib, config, pkgs, ... }:

let
  cfg = config.modules.helix;

in
{
  options.modules.helix = with lib; {
    language-server = mkOption {
      description = "Languageserver configuration";
      type = (types.attrsOf (types.attrsOf types.anything));
      default = { };
    };
    languages = mkOption {
      description = "Language configurations";
      type = (types.attrsOf (types.attrsOf types.anything));
      default = { };
    };
  };

  config.programs.helix = {
    enable = true;
    defaultEditor = true;

    # Some packages that are required for the language servers
    extraPackages = with pkgs; [
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

    ignores = [
      "target/"
      "node_modules/"
      ".git/"
    ];

    languages.language = lib.attrsets.mapAttrsToList (name: value: value // { inherit name; }) cfg.languages;
    languages.language-server = cfg.language-server;
  };

  config.modules.helix = {
    #
    # Language Configurations
    #
    # See: https://github.com/helix-editor/helix/wiki/Language-Server-Configurations

    # HTML
    language-server = {
      emmet-ls = { command = "${pkgs.emmet-ls}/bin/emmet-ls"; args = [ "--stdio" ]; };
      superhtml = { command = "${pkgs.superhtml}/bin/superhtml"; args = [ "lsp" ]; };
    };
    languages.html.language-servers = [ "superhtml" "emmet-ls" ];

    # Nix
    language-server.nil.command = "${pkgs.nil}/bin/nil";
    languages.nix = {
      auto-format = true;
      formatter.command = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
    };

    # Rust
    language-server.rust-analyzer.config.check.command = "clippy";

    # TOML
    language-server.taplo.command = "${pkgs.taplo}/bin/taplo";
    languages.toml.auto-format = true;

    # YAML
    language-server.yaml-language-server = {
      command = "${pkgs.yaml-language-server}/bin/yaml-language-server";
      config.yaml.schemas = {
        "https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json" = ".gitlab-ci*.{yml,yaml}";
        "https://json.schemastore.org/github-workflow.json" = ".github/workflows/*.{yml,yaml}";
        "https://json.schemastore.org/kustomization.json" = "kustomization.{yml,yaml}";
        "https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json" = "{docker_,}compose.{yml,yaml}";
      };
    };
  };
}
