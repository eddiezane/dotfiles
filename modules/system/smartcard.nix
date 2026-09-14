{ pkgs, ... }:

let
  syncBrowserPki = pkgs.writeShellApplication {
    name = "sync-browser-pki";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      gnugrep
      gawk
      nssTools
      openssl
      procps
    ];
    text =
      ''
        export P11_KIT_PROXY_MODULE=${pkgs.p11-kit}/lib/p11-kit-proxy.so
      ''
      + builtins.readFile ./sync-browser-pki.sh;
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
    syncBrowserPki
  ];
}
