{
  lib,
  pkgs,
  secrets,
  ...
}:

let
  cargoRegistries = lib.recursiveUpdate secrets.cargoRegistries {
    crates-io.protocol = "sparse";
  };
  cargoConfig = {
    build.rustc-wrapper = "${pkgs.sccache}/bin/sccache";
    registry.global-credential-providers = [ "cargo:token" ];
    registries = cargoRegistries;
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
