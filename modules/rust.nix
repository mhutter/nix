{ pkgs, ... }:

{
  home.packages = with pkgs; [ rustup cargo-watch cargo-nextest bacon ];

  home.file = {
    ".cargo/config.toml".text = ''
      [registries.crates-io]
      protocol = "sparse"

      [build]
      rustc-wrapper = "${pkgs.sccache}/bin/sccache"
    '';
  };
}
