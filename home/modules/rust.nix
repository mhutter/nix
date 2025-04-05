{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bacon
    cargo-expand
    cargo-generate
    cargo-nextest
    cargo-outdated
    cargo-watch
    cargo-wizard
    rustup
  ];

  home.file = {
    ".cargo/config.toml".text = ''
      [registries.crates-io]
      protocol = "sparse"

      [build]
      rustc-wrapper = "${pkgs.sccache}/bin/sccache"
    '';
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];
}
