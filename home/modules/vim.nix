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
      nodejs
      # Language Server
      gopls
      jsonnet-language-server
      lua-language-server
      nil
      nixpkgs-fmt
      rust-analyzer
      # prettier is in default.nix
    ];
  };
}
