{ pkgs, ... }:

{
  programs.helix = {
    enable = true;

    settings = {
      theme = "custom";
      editor = {
        bufferline = "always";
        color-modes = true;
        statusline = {
          center = [ "workspace-diagnostics" ];
        };
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
      };
      keys.normal = {
        space.space = "file_picker";
      };
    };

    languages = [
      {
        name = "nix";
        auto-format = true;
        language-server = { command = "${pkgs.rnix-lsp}/bin/rnix-lsp"; };
      }
      {
        name = "rust";
        config.cargo.features = "all";
        language-server.command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
      }
    ];

    themes.custom = {
      inherits = "sonokai";
      "ui.virtual.inlay-hint" = "grey_dim";
    };
  };
}
