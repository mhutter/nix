{ fetchurl
, stdenv
, autoPatchelfHook
, makeWrapper
, lib

  # Packages
, alsa-lib
, curl
, dpkg
, gdk-pixbuf
, glib
, gtk3
, hidapi
, libGL
, libX11
, libXScrnSaver
, libpulseaudio
, libresample
, libuuid
, openssl
, systemdLibs
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
  version = "4.1.5";
  pname = "cti";
  src = fetchurl {
    url = "https://wwcom.ch/downloads/cti_4_1_5.deb";
    sha256 = "1v3nladgxm7mgphif7w6rn6ysm9gd3kaby5ycvp0s1bzsv3jcdny";
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

