# Linear desktop app, repackaged from the upstream Windows installer.
#
# Linear doesn't ship a Linux build, but the app is a thin Electron wrapper
# around https://linear.app whose app.asar has no Windows-specific native
# modules, so it runs as-is on nixpkgs' Electron. Only the x64 app.asar and the
# icons are taken from the installer; the Windows Electron runtime is discarded.
#
# Known gaps on Linux: the "launch coding agent in terminal" feature only
# supports Windows and macOS, and there's no unread badge.
#
# The app's built-in self-updater can't work here (it stays inactive when run
# unpackaged via `electron app.asar`), so upgrade manually:
#   1. Find the latest version in https://releases.linear.app/latest.yml
#   2. Update `version` below, and `electron` in the overlay if the app's
#      Electron major version changed (check the exe with
#      `strings Linear.exe | grep -m1 -o 'Electron/[0-9.]*'`).
#   3. Get the new hash with
#        nix store prefetch-file 'https://releases.linear.app/Linear%20Setup%20<version>.exe'
#      and update `hash` below.
{
  lib,
  stdenvNoCC,
  fetchurl,
  p7zip,
  icoutils,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  electron,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "linear-desktop";
  version = "1.32.8";

  src = fetchurl {
    url = "https://releases.linear.app/Linear%20Setup%20${finalAttrs.version}.exe";
    name = "linear-setup-${finalAttrs.version}.exe";
    hash = "sha256-RdqwQzepMx9bnyX6+3wVu5G85XHgeMyuS9b4lo4QNUo=";
  };

  nativeBuildInputs = [
    p7zip
    icoutils
    makeWrapper
    copyDesktopItems
  ];

  # The NSIS installer embeds per-arch app archives; take the x64 one.
  unpackPhase = ''
    runHook preUnpack

    7z x -y $src '$PLUGINSDIR/app-64.7z' >/dev/null
    7z x -y '$PLUGINSDIR/app-64.7z' -oapp resources/app.asar Linear.exe >/dev/null

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 app/resources/app.asar $out/share/linear-desktop/app.asar

    wrestool -x -t 14 app/Linear.exe -o linear.ico
    icotool -x linear.ico
    for png in linear_*.png; do
      size=$(echo "$png" | sed -E 's/^linear_[0-9]+_([0-9]+)x.*/\1/')
      install -Dm644 "$png" $out/share/icons/hicolor/''${size}x''${size}/apps/linear.png
    done

    makeWrapper ${lib.getExe electron} $out/bin/linear \
      --add-flags $out/share/linear-desktop/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set CHROME_DESKTOP linear.desktop

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "linear";
      desktopName = "Linear";
      comment = finalAttrs.meta.description;
      exec = "linear %U";
      icon = "linear";
      categories = ["Office" "ProjectManagement"];
      mimeTypes = ["x-scheme-handler/linear"];
      startupWMClass = "linear";
    })
  ];

  meta = {
    description = "Linear desktop client";
    homepage = "https://linear.app";
    license = lib.licenses.unfree;
    sourceProvenance = [lib.sourceTypes.binaryBytecode];
    platforms = ["x86_64-linux"];
    mainProgram = "linear";
  };
})
