{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation {
  pname = "k0s";
  version = "1.36.3+k0s.2";

  src = fetchurl {
    url = "https://github.com/k0sproject/k0s/releases/download/v1.36.3%2Bk0s.2/k0s-v1.36.3%2Bk0s.2-amd64";
    hash = "sha256-+LJ4ulqZOM7SJjgUhKDzG2v6KThwOUnfI1R04Dx3Ssw=";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm755 "$src" "$out/bin/k0s"
  '';

  meta = {
    description = "Zero-friction Kubernetes distribution";
    homepage = "https://k0sproject.io";
    license = lib.licenses.asl20;
    mainProgram = "k0s";
    platforms = [ "x86_64-linux" ];
  };
}
