{ pkgs, ... }:

{
  # Dependencies
  home.packages = with pkgs; [
    clang
    go
    nodejs-slim
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  # TODO: Install AstroNvim
  # TODO: ensure config is checked out/cloned

  # Neovide (and most GUI apps) do not work on non-NixOS systems
}
