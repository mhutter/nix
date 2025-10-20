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
stdenv.mkDerivation {
  version = "4.1.15-2";
  pname = "cti";
  src = fetchurl {
    url = "https://wwcom.ch/downloads/cti_4_1_15-2.deb";
    # use `nix-prefetch-url` to determine new hashes
    sha256 = "0g35218wq215yjvc7gi19dc36sm307rxjax9a2yqlm77axj9rla7";
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
