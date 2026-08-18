{ pkgs, ... }:

let
  setupBrowserSmartcard = pkgs.writeShellApplication {
    name = "setup-browser-smartcard";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      gnugrep
      nssTools
      openssl
      procps
    ];
    text = ''
      bundle="''${1:-''${SMARTCARD_PKI_BUNDLE:-$HOME/Codez/dotfiles/assets/pki/smartcard/bundle.der.p7b}}"

      if [[ ! -f "$bundle" ]]; then
        printf 'Certificate bundle not found: %s\n' "$bundle" >&2
        exit 1
      fi

      if pgrep -x chrome >/dev/null || pgrep -x chromium >/dev/null; then
        printf 'Close Chrome or Chromium before running this command.\n' >&2
        exit 1
      fi

      if [[ -d "$HOME/.pki/nssdb" ]]; then
        nssdb="$HOME/.pki/nssdb"
      else
        data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
        nssdb="$data_home/pki/nssdb"
      fi

      mkdir -p "$nssdb"
      chmod 700 "$nssdb"

      if [[ ! -f "$nssdb/cert9.db" ]]; then
        certutil -N --empty-password -d "sql:$nssdb"
      fi

      if modutil -dbdir "sql:$nssdb" -list | grep -Fq 'p11-kit-proxy'; then
        modutil -force -dbdir "sql:$nssdb" -delete p11-kit-proxy
      fi

      workdir="$(mktemp -d)"
      trap 'rm -rf "$workdir"' EXIT

      openssl pkcs7 -inform DER -in "$bundle" -print_certs -out "$workdir/all.pem"
      awk -v dir="$workdir" '
        /-----BEGIN CERTIFICATE-----/ {
          file = sprintf("%s/cert-%03d.pem", dir, ++count)
          writing = 1
        }
        writing { print > file }
        /-----END CERTIFICATE-----/ {
          close(file)
          writing = 0
        }
      ' "$workdir/all.pem"

      anchors=0
      intermediates=0
      shopt -s nullglob
      for certificate in "$workdir"/cert-*.pem; do
        subject="$(openssl x509 -in "$certificate" -noout -subject -nameopt RFC2253)"
        issuer="$(openssl x509 -in "$certificate" -noout -issuer -nameopt RFC2253)"
        fingerprint="$(openssl x509 -in "$certificate" -noout -fingerprint -sha256 | cut -d= -f2 | tr -d :)"
        nickname="smartcard-$fingerprint"

        if [[ "''${subject#subject=}" == "''${issuer#issuer=}" ]]; then
          trust='C,,'
          ((anchors += 1))
        else
          trust=',,'
          ((intermediates += 1))
        fi

        certutil -D -d "sql:$nssdb" -n "$nickname" >/dev/null 2>&1 || true
        certutil -A -d "sql:$nssdb" -n "$nickname" -t "$trust" -i "$certificate"
      done

      modutil -force -dbdir "sql:$nssdb" -add p11-kit-proxy \
        -libfile ${pkgs.p11-kit}/lib/p11-kit-proxy.so

      printf 'Configured %s with %d trust anchors and %d intermediates.\n' \
        "$nssdb" "$anchors" "$intermediates"
    '';
  };
in
{
  services.pcscd = {
    enable = true;
    ignoreReaderNames = [ "YubiKey" ];
  };

  environment.etc."pkcs11/modules/opensc-pkcs11".text = ''
    module: ${pkgs.opensc}/lib/opensc-pkcs11.so
  '';

  environment.systemPackages = with pkgs; [
    nssTools
    opensc
    p11-kit
    pcsc-tools
    setupBrowserSmartcard
  ];
}
