{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ink";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "borghei";
    repo = "ink";
    tag = "v${finalAttrs.version}";
    hash = "sha256-I0a+7NTEkvlCmexRNAIU17PA+5nb4Mmu/cwv0Qffzwg=";
  };

  cargoHash = "sha256-e7VlqRoWGkYIEOTVITP4kQiXvP2ZcRMgPE2i/7F6vfg=";

  # Tests rely on snapshot files and the network
  doCheck = false;

  meta = {
    description = "Terminal markdown reader with syntax highlighting, inline images and mermaid diagrams";
    homepage = "https://github.com/borghei/ink";
    license = lib.licenses.unfree; # custom license: free of charge, no resale
    mainProgram = "ink";
  };
})
