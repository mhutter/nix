{
  fetchurl,
  stdenv,
  autoPatchelfHook,
  dpkg,
  makeWrapper,
  wrapGAppsHook3,
  lib,

  # Packages
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  krb5,
  libayatana-appindicator,
  libcap_ng,
  libdrm,
  libgbm,
  libglvnd,
  libnotify,
  libpulseaudio,
  libsecret,
  libseccomp,
  libuuid,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  libxtst,
  nspr,
  nss,
  pango,
  pipewire,
  qemu_kvm,
  systemdLibs,
}:
let
  # Libraries that are dlopen'ed at runtime, so autoPatchelfHook cannot find
  # them from DT_NEEDED entries.
  runtimeLibs = [
    # tray icon
    libayatana-appindicator
    # libEGL.so.1 / libGLESv2.so.2, dispatching to /run/opengl-driver/lib
    libglvnd
    # SPNEGO/Kerberos auth (libgssapi_krb5.so.2)
    krb5
    libnotify
    libpulseaudio
    # screen sharing
    pipewire
    # Electron safeStorage
    libsecret
  ];

in
stdenv.mkDerivation (finalAttrs: {
  pname = "claude-desktop";
  version = "1.52386.0";

  src = fetchurl {
    # The URL carries an opaque build id alongside the version, and both change
    # on every release. Grab the current .deb link from
    # https://claude.ai/download and use `nix-prefetch-url` for the hash.
    url = "https://downloads.claude.ai/releases/linux/x64/${finalAttrs.version}/Claude-1003ca8d443708006c167ffbd0f9695343643af1.deb";
    hash = "sha256-nF0RPqLDHA1PYHXALmGAv0q1PTVza5pJfODoT2LpZUs=";
  };

  buildInputs = [
    stdenv.cc.cc.lib

    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libuuid
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    libxtst
    nspr
    nss
    pango
    systemdLibs

    # for the bundled resources/virtiofsd
    libcap_ng
    libseccomp
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    wrapGAppsHook3
  ];

  # Wrap manually below so the gapps arguments end up on the one wrapper we
  # create ourselves.
  dontWrapGApps = true;

  # dpkg-deb -x would try to restore the setuid bit on chrome-sandbox, which
  # the build sandbox does not allow (and the store would strip anyway).
  unpackCmd = ''
    mkdir extracted
    dpkg-deb --fsys-tarfile "$src" \
      | tar -x --no-same-owner --no-same-permissions -C extracted
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib" "$out/share"
    mv usr/lib/claude-desktop "$out/lib/"
    mv usr/share/applications usr/share/icons "$out/share/"

    # Exec= is unqualified in the shipped entry; don't depend on $PATH. Also
    # covers the two Desktop Actions.
    substituteInPlace "$out/share/applications/com.anthropic.Claude.desktop" \
      --replace-fail "Exec=claude-desktop" "Exec=$out/bin/claude-desktop"

    runHook postInstall
  '';

  # Keep the binary next to its resources/ so Electron's process.resourcesPath
  # still resolves.
  postFixup = ''
    makeWrapper "$out/lib/claude-desktop/claude-desktop" "$out/bin/claude-desktop" \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}" \
      --prefix PATH : "${lib.makeBinPath [ qemu_kvm ]}"
  '';

  meta = {
    description = "Desktop application for Claude.ai";
    homepage = "https://claude.ai/download";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "claude-desktop";
  };
})
