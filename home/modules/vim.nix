{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    # Prevent HM module from trying to overwrite ~/.config/nvim/init.lua
    sideloadInitLua = true;

    defaultEditor = true;
    vimAlias = true;
    vimdiffAlias = true;

    withNodeJs = true;
    withPython3 = false;
    withRuby = false;

    # For whatever reason, the above does not make NodeJS available to LSP servers
    extraPackages = with pkgs; [
      # Plugin runtimes
      nodejs

      # Plugin dependencies
      fzf
      ripgrep
      tree-sitter

      # Language Server
      gopls
      jsonnet-language-server
      lua-language-server
      nil
      nixfmt
      # typescript-language-server

      # rust-analyzer is installed via rustup
      # prettier is in default.nix
    ];
  };
}
