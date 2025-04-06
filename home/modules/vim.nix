{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    defaultEditor = true;
    vimAlias = true;
    vimdiffAlias = true;

    withNodeJs = true;
    # For whatever reason, the above does not make NodeJS available to LSP servers
    extraPackages = with pkgs; [
      # Plugin runtimes
      nodejs

      # Plugin dependencies
      fzf
      ripgrep

      # Language Server
      gopls
      jsonnet-language-server
      lua-language-server
      nil
      nixfmt-rfc-style

      # rust-analyzer is installed via rustup
      # prettier is in default.nix
    ];
  };
}
