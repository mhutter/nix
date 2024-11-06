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
    mold
    rustup
  ];

  home.file = {
    ".cargo/config.toml".text = ''
      [registries.crates-io]
      protocol = "sparse"

      [build]
      rustc-wrapper = "${pkgs.sccache}/bin/sccache"
      rustflags = ["-Clink-arg=-fuse-ld=mold"]
    '';
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];
}
