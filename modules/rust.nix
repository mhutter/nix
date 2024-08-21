{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bacon
    cargo-expand
    cargo-nextest
    # TODO: Reenable once building again
    # cargo-outdated
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
