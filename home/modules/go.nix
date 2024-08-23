{ pkgs, ... }: {
  home.packages = with pkgs; [
    # go  # installed via pacman for now
    golangci-lint
  ];
}
