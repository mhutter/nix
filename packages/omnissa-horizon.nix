{
  autoPatchelfHook,
  fetchurl,
  makeWrapper,
  stdenv,

  # Packages
  dpkg,
  file,
  gtkmm3,
  libXScrnSaver,
  libpulseaudio,
  xorg,
}:
let
  buildInputs = [
    file # for libmagic
    gtkmm3
    libXScrnSaver
    libpulseaudio
    xorg.libXtst
    xorg.libxkbfile
  ];

in
stdenv.mkDerivation {
  version = "8.15.0";
  pname = "omnissa-horizon-client";
  src = fetchurl {
    url = "https://download3.omnissa.com/software/CART26FQ1_LIN64_DEBPKG_2503/Omnissa-Horizon-Client-2503-8.15.0-14256322247.x64.deb";
    hash = "sha256-D4xE5cXiPODlUrEqag/iHkZjEkpxY/rOABwx4xsKRV0=";
  };

  inherit buildInputs;
  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];
  autoPatchelfIgnoreMissingDeps = true;

  unpackCmd = ''
    dpkg-deb -x "$src" extracted
  '';

  installPhase = ''
    runHook preInstall

    mv usr $out
    substituteInPlace $out/bin/* \
      --replace /usr $out

    runHook postInstall
  '';

  meta = {
    mainProgram = "horizon-client";
  };
}
