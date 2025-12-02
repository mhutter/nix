{ pkgs, ... }:

let
  cargoConfig = {
    registries.crates-io.protocol = "sparse";
    build.rustc-wrapper = "${pkgs.sccache}/bin/sccache";
  };
in
{
  home.packages = with pkgs; [
    bacon
    cargo-expand
    cargo-generate
    cargo-nextest
    cargo-outdated
    cargo-watch
    gcc
    rustup
  ];

  home.file.".cargo/config.toml".source =
    (pkgs.formats.toml { }).generate "cargo-config.toml"
      cargoConfig;

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];
}
