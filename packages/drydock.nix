{
  buildGo127Module,
  fetchFromGitHub,
  lib,
}:
buildGo127Module (finalAttrs: {
  pname = "drydock";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "sholdee";
    repo = "drydock";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OTLOfsIujXbq3KNN6M7DMtfVxqCw/V2qbCnhIEBs/hY=";
  };

  vendorHash = "sha256-JaUvz2O3tj8BEp1xKrBF6zmsd1FE/PEASYAWrFgzYuw=";

  subPackages = [ "cmd/drydock" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${finalAttrs.version}"
  ];

  meta = {
    description = "Runtime-offline Argo CD desired-state analysis";
    homepage = "https://github.com/sholdee/drydock";
    license = lib.licenses.asl20;
    mainProgram = "drydock";
  };
})
