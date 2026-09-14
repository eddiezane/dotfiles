# Local wildcard DNS for dev/internal domains, via a loopback dnsmasq that
# systemd-resolved forwards to (split-DNS). This is the companion to
# hosts.nix: /etc/hosts handles exact-match single names; dnsmasq handles
# wildcards (`*.example.internal`) that /etc/hosts and resolved can't express.
#
# How it fits together:
#   * systemd-resolved stays the primary resolver (Tailscale MagicDNS and
#     Avahi mDNS paths are untouched). Private, off-repo drop-ins route selected
#     suffixes to dnsmasq on 127.0.0.1; everything else keeps going to the
#     per-link DNS NetworkManager provides.
#   * dnsmasq is authoritative ONLY for those suffixes and never forwards
#     upstream. The actual entries live off-repo in /etc/dnsmasq.d/*.conf,
#     hand-editable without a rebuild — same philosophy as hosts.nix.
#
# Two kinds of change:
#   * New host/IP UNDER an existing suffix  -> edit /etc/dnsmasq.d, no rebuild.
#   * A new top-level suffix                -> keep it out of Git by creating:
#       /etc/systemd/resolved.conf.d/90-local-routing-domains.conf
#       [Resolve]
#       Domains=~example.internal
# After editing /etc/dnsmasq.d, run:  sudo systemctl restart dnsmasq
# (a plain reload/SIGHUP does NOT re-read `address=` wildcard lines).
# After editing the resolved drop-in, run:
#   sudo systemctl restart systemd-resolved
#
# Starter /etc/dnsmasq.d/dev.conf (create on a fresh install; off-repo):
#
#   # one line replaces an enumerated wildcard block in /etc/hosts
#   address=/example.internal/127.0.0.1
#
#   # internal clusters, add as needed (and route each suffix through the
#   # private resolved drop-in above)
{ ... }:

{
  services.dnsmasq = {
    enable = true;

    # Don't let the module register dnsmasq as the system resolver or touch
    # resolv.conf — resolved is primary and forwards to us explicitly.
    resolveLocalQueries = false;

    settings = {
      # Bind only 127.0.0.1:53 so we never collide with resolved's stub on
      # 127.0.0.53:53. bind-interfaces stops dnsmasq wildcard-binding :53.
      listen-address = "127.0.0.1";
      bind-interfaces = true;

      # Authoritative for the dev domains only; no upstream. resolved only ever
      # sends us routed queries, so unmatched names simply return NXDOMAIN.
      no-resolv = true;

      # Off-repo, hand-managed entries (the `address=/.../ip` lines). Only
      # *.conf so editor backup files are ignored.
      conf-dir = "/etc/dnsmasq.d/,*.conf";
    };
  };

  # Guarantee the hand-managed configuration directories on clean installs.
  # Their contents remain local and off-repo.
  systemd.tmpfiles.rules = [
    "d /etc/dnsmasq.d 0755 root root -"
    "d /etc/systemd/resolved.conf.d 0755 root root -"
  ];

  # Split-DNS: private routing domains from the off-repo drop-in use the local
  # dnsmasq. Merges with DNSSEC/FallbackDNS settings from networking.nix.
  services.resolved.settings.Resolve = {
    DNS = [ "127.0.0.1" ];
  };
}
