{
  fetchurl,
  stdenv,
  autoPatchelfHook,
  makeWrapper,
  lib,

  # Packages
  alsa-lib,
  curl,
  dpkg,
  gdk-pixbuf,
  glib,
  gtk3,
  hidapi,
  libGL,
  libX11,
  libXScrnSaver,
  libpulseaudio,
  libresample,
  libuuid,
  openssl,
  systemdLibs,
}:
let
  buildInputs = [
    stdenv.cc.cc.lib

    alsa-lib
    curl
    gdk-pixbuf
    glib
    gtk3
    hidapi
    libGL
    libX11
    libXScrnSaver
    libpulseaudio
    libresample
    libuuid
    openssl
    systemdLibs
  ];

in
stdenv.mkDerivation rec {
  version = "4.2.12";
  pname = "cti";
  src = fetchurl {
    url = "https://wwcom.ch/downloads/cti_${builtins.replaceStrings [ "." ] [ "_" ] version}.deb";
    # use `nix-prefetch-url` to determine new hashes
    sha256 = "04hwfqray6113ji5ir2gjfr0vy1l1zxjrymcsxsammraqys4cc0w";
  };

  inherit buildInputs;
  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  unpackCmd = ''
    dpkg-deb -x "$src" extracted
  '';

  installPhase = ''
    mkdir "$out"
    mv * "$out/"
    rm -rf "$out/usr/local"
    # substituteInPlace "$out/bin/pbxcti" \
    #   --replace "/opt" "$out/opt"
    # wrapProgram "$out/opt/pbxcti/pbxcti" \
    # --prefix LD_LIBRARY_PATH : "$out" > "$out/bin/pbxcti"
    makeWrapper "$out/opt/pbxcti/pbxcti"  "$out/bin/pbxcti" \
      --set LD_LIBRARY_PATH $out:${lib.makeLibraryPath buildInputs}
  '';

  meta = {
    mainProgram = "pbxcti";
  };
}
