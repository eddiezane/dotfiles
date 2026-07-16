# Local wildcard DNS for dev/internal domains, via a loopback dnsmasq that
# systemd-resolved forwards to (split-DNS). This is the companion to
# hosts.nix: /etc/hosts handles exact-match single names; dnsmasq handles
# WILDCARDS (`*.uds.dev`) that /etc/hosts and resolved can't express.
#
# How it fits together:
#   * systemd-resolved stays the primary resolver (Tailscale MagicDNS and
#     Avahi mDNS paths are untouched). It routes only the `devDomains` suffixes
#     below to dnsmasq on 127.0.0.1; everything else keeps going to the
#     per-link DNS NetworkManager provides.
#   * dnsmasq is authoritative ONLY for those suffixes and never forwards
#     upstream. The actual entries live off-repo in /etc/dnsmasq.d/*.conf,
#     hand-editable without a rebuild — same philosophy as hosts.nix.
#
# Two kinds of change:
#   * New host/IP UNDER an existing suffix  -> edit /etc/dnsmasq.d, no rebuild.
#   * A brand-new top-level suffix          -> add one line to `devDomains`
#                                              below + rebuild (so resolved
#                                              knows to route it here).
# After editing /etc/dnsmasq.d, run:  sudo systemctl restart dnsmasq
# (a plain reload/SIGHUP does NOT re-read `address=` wildcard lines).
#
# Starter /etc/dnsmasq.d/dev.conf (create on a fresh install; off-repo):
#
#   # one line replaces the whole enumerated *.uds.dev block in /etc/hosts
#   address=/uds.dev/127.0.0.1
#
#   # internal clusters, add as needed (remember to also list the suffix
#   # in devDomains below so resolved routes it here)
{ lib, ... }:

let
  # Suffixes systemd-resolved routes to the local dnsmasq. dnsmasq answers
  # these (and every subdomain) from /etc/dnsmasq.d/*.conf.
  devDomains = [
    "uds.dev"
  ];
in
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
      # sends us `devDomains` queries, so unmatched names simply return NXDOMAIN.
      no-resolv = true;

      # Off-repo, hand-managed entries (the `address=/.../ip` lines). Only
      # *.conf so editor backup files are ignored.
      conf-dir = "/etc/dnsmasq.d/,*.conf";
    };
  };

  # dnsmasq refuses to start if conf-dir is *missing* (an empty dir is fine).
  # Guarantee the directory declaratively so a clean install starts before any
  # entries exist; the files inside stay hand-managed / off-repo.
  systemd.tmpfiles.rules = [ "d /etc/dnsmasq.d 0755 root root -" ];

  # Split-DNS: 127.0.0.1 (dnsmasq) is used ONLY for the routing domains below.
  # Merges with the DNSSEC/FallbackDNS settings from networking.nix.
  services.resolved.settings.Resolve = {
    DNS = [ "127.0.0.1" ];
    Domains = map (d: "~${d}") devDomains;
  };
}
