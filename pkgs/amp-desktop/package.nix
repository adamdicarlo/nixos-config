# Amp desktop app, repackaged from the upstream Debian repository at
# https://static.ampcode.com/linux/.
#
# The app's built-in self-updater can't work on NixOS, so upgrade manually:
#   1. Find the latest version in
#      https://static.ampcode.com/linux/dists/stable/main/binary-amd64/Packages
#   2. Update `version` below.
#   3. Get the new hash with
#        nix store prefetch-file https://static.ampcode.com/linux/<version>/amp-desktop-<version>-amd64.deb
#      and update `hash` below.
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libappindicator-gtk3,
  libdrm,
  libGL,
  libgbm,
  libnotify,
  libsecret,
  libuuid,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  libxscrnsaver,
  libxtst,
  nspr,
  nss,
  pango,
  systemd,
  vulkan-loader,
  xdg-utils,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "amp-desktop";
  version = "0.1.29901961";

  src = fetchurl {
    url = "https://static.ampcode.com/linux/${finalAttrs.version}/amp-desktop-${finalAttrs.version}-amd64.deb";
    hash = "sha256-79Kghhg5YlZAE1Z3/P/irAzNlB08OmClGTOkj0ATpW0=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
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
    libnotify
    libsecret
    libuuid
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    libxscrnsaver
    libxtst
    nspr
    nss
    pango
  ];

  # dlopen()ed at runtime, so autoPatchelfHook can't discover them.
  runtimeDependencies = [
    (lib.getLib systemd)
    libGL
    libappindicator-gtk3
    libnotify
    libsecret
    vulkan-loader
  ];

  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp -r opt/amp $out/share/amp-desktop
    cp -r usr/share/icons $out/share/icons

    install -Dm644 usr/share/applications/amp-desktop.desktop \
      $out/share/applications/amp-desktop.desktop
    substituteInPlace $out/share/applications/amp-desktop.desktop \
      --replace-fail /opt/amp/amp-desktop amp-desktop

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper $out/share/amp-desktop/amp-desktop $out/bin/amp-desktop \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${lib.makeBinPath [xdg-utils]} \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
  '';

  meta = {
    description = "Amp, the frontier coding agent (desktop app)";
    homepage = "https://ampcode.com";
    license = lib.licenses.unfree;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = ["x86_64-linux"];
    mainProgram = "amp-desktop";
  };
})
