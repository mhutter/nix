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

  # Current defaults:
  # https://raw.githubusercontent.com/Canop/bacon/main/defaults/default-prefs.toml
  baconConfig.keybindings = {
    c = "job:clippy";
    alt-c = "job:clippy-all";
    p = "job:pedantic";
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

  home.file.".config/bacon/prefs.toml".source =
    (pkgs.formats.toml { }).generate "bacon-prefs.toml"
      baconConfig;

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];
}
