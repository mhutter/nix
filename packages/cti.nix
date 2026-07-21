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
  gsettings-desktop-schemas,
  gtk3,
  hidapi,
  libGL,
  libX11,
  libXScrnSaver,
  libayatana-appindicator,
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
    # dlopen'ed at runtime for the tray icon
    libayatana-appindicator
    libpulseaudio
    libresample
    libuuid
    openssl
    systemdLibs
  ];

in
stdenv.mkDerivation rec {
  version = "4.3.4";
  pname = "cti";
  src = fetchurl {
    url = "https://wwcom.ch/downloads/cti_${builtins.replaceStrings [ "." ] [ "_" ] version}.deb";
    # use `nix-prefetch-url` to determine new hashes
    sha256 = "00a01jnhbdpd310gg2yx4pzx6q6qxkpz4kck7kvx92qnx8s5j4xy";
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
      --set LD_LIBRARY_PATH $out:${lib.makeLibraryPath buildInputs} \
      --prefix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}"
  '';

  meta = {
    mainProgram = "pbxcti";
  };
}
