{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      clang
      go
      nodejs
      unzip
    ];
  };

  # TODO: Install AstroNvim
  # TODO: ensure config is checked out/cloned

  # Neovide (and most GUI apps) do not work on non-NixOS systems
}
