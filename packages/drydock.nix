{
  buildGo127Module,
  fetchFromGitHub,
  lib,
}:
buildGo127Module (finalAttrs: {
  pname = "drydock";
  version = "0.2.10";

  src = fetchFromGitHub {
    owner = "sholdee";
    repo = "drydock";
    tag = "v${finalAttrs.version}";
    hash = "sha256-f2v1Nmhhb86GMtVOpuR0jDldBVXLHjOiQYQC/0JfuLc=";
  };

  vendorHash = "sha256-5OKVgNjX7wtqXXz7XeRxbvLQ8lbbwZmEhumVdZO6Lec=";

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
