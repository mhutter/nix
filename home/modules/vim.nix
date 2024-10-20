{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    defaultEditor = true;
    vimAlias = true;
    vimdiffAlias = true;

    withNodeJs = true;
    # For whatever reason, the above does not make NodeJS available to LSP servers
    extraPackages = [ pkgs.nodejs ];
  };
}
