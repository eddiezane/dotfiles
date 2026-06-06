# signal-desktop, packaged from the upstream .deb so we can run a version
# nixpkgs hasn't picked up yet. Modeled on nixpkgs' slack/linux.nix which
# does the same dpkg-extract + patchelf + makeWrapper dance.
#
# When nixpkgs catches up to upstream (>= the version pinned here),
# remove the overlay in hosts/common.nix and delete this file.
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  makeWrapper,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  curl,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libGL,
  libappindicator-gtk3,
  libdrm,
  libnotify,
  libpulseaudio,
  libsecret,
  libuuid,
  libxcb,
  libxkbcommon,
  libgbm,
  nspr,
  nss,
  pango,
  pipewire,
  systemd,
  wayland,
  xdg-utils,
  libxtst,
  libxscrnsaver,
  libxrender,
  libxrandr,
  libxi,
  libxfixes,
  libxext,
  libxdamage,
  libxcursor,
  libxcomposite,
  libx11,
  libxshmfence,
}:
stdenv.mkDerivation rec {
  pname = "signal-desktop";
  version = "8.13.0";

  src = fetchurl {
    url = "https://updates.signal.org/desktop/apt/pool/s/signal-desktop/signal-desktop_${version}_amd64.deb";
    hash = "sha256-00rHegQphSqB7038Mlx3WrMsLfdp7zKZ243QEOsEpYo=";
  };

  rpath =
    lib.makeLibraryPath [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      curl
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libGL
      libappindicator-gtk3
      libdrm
      libnotify
      libpulseaudio
      libsecret
      libuuid
      libxcb
      libxkbcommon
      libgbm
      nspr
      nss
      pango
      pipewire
      stdenv.cc.cc
      systemd
      wayland
      libx11
      libxscrnsaver
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxi
      libxrandr
      libxrender
      libxtst
      libxshmfence
    ]
    + ":${lib.getLib stdenv.cc.cc}/lib64";

  buildInputs = [ gtk3 ]; # for GSETTINGS_SCHEMAS_PATH
  nativeBuildInputs = [ dpkg makeWrapper ];

  dontUnpack = true;
  dontBuild = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall

    dpkg --fsys-tarfile $src | tar --extract
    rm -rf usr/share/lintian

    # The .deb has /opt/Signal/ (the app + binary) and /usr/share/ (icons +
    # .desktop file). No /usr/bin/ at all — we synthesize that ourselves.
    mkdir -p $out
    mv usr/share $out/share
    mkdir -p $out/opt
    mv opt/Signal $out/opt/Signal
    chmod -R g-w $out

    # Also include *.node — native node modules (e.g. ringrtc) are ELF shared
    # objects but don't match the *.so* pattern. They dlopen libs by bare name
    # at runtime so they need rpath set too.
    for file in $(find $out -type f \( -perm /0111 -o -name \*.so\* -o -name \*.node \)); do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" 2>/dev/null || true
      patchelf --set-rpath ${rpath}:$out/opt/Signal $file 2>/dev/null || true
    done

    # Wrap with Wayland flags consistent with the rest of the system, and also
    # bake LD_LIBRARY_PATH so any remaining bare-name dlopen calls resolve.
    mkdir -p $out/bin
    makeWrapper $out/opt/Signal/signal-desktop $out/bin/signal-desktop \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix LD_LIBRARY_PATH : "${rpath}:$out/opt/Signal" \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer --enable-wayland-ime=true}}"

    # Point the .desktop file's Exec= at our wrapper. Upstream ships
    # `Exec=/opt/Signal/signal-desktop %U` which won't exist on a NixOS host.
    substituteInPlace $out/share/applications/signal-desktop.desktop \
      --replace-fail "/opt/Signal/signal-desktop" "$out/bin/signal-desktop"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Private messenger for Linux (8.13.0 binary override; nixpkgs is behind)";
    homepage = "https://signal.org/";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "signal-desktop";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
