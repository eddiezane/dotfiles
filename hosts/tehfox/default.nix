# tehfox — headless AI/inference server (Ryzen 5900X + RTX 3080).
# Server-safe base only (no hosts/profiles/desktop.nix). WoL, no LUKS,
# Ollama + Open WebUI (+ local SearXNG) over Tailscale.
{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/disko/btrfs.nix
    ./hardware.nix
  ];

  # 980 PRO (faster, hard-to-reach top slot → stays; the 970 EVO gets pulled
  # later). by-id so the target survives that re-enumeration.
  _module.args.diskoArgs = {
    disk = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NG0NC05758M";
    swapSize = "16G"; # overflow only; zram handles the common case
    espSize = "1G";
  };

  # --- Remote access: Tailscale SSH only ------------------------------------

  # OpenSSH off → remote shell is Tailscale SSH (`tailscale up --ssh`), no port
  # 22 anywhere. Persists in /var/lib/tailscale; password account is the console
  # fallback. (Tailnet ACL uses "check" → periodic browser re-auth.)
  services.openssh.enable = false;
  services.tailscale.extraUpFlags = [ "--ssh" ];

  # Inert while OpenSSH is off; kept so re-enabling it is one line.
  users.users.eddiezane.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKG0lTesnNipOivciXzdFw5NleibHykQ6V3Dp9ic1yzg SSH Key"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII76gJY0VgQhPOXpkihjBZDwK2OAkapxghO/21J16Mxl TEHUNICORN"
  ];

  # Wake-on-LAN (also needs "Power On By PCIe" + ErP off in BIOS — manual).
  networking.interfaces.enp6s0.wakeOnLan.enable = true;

  # --- Tailscale exit node ---------------------------------------------------

  # "both" (overrides base "client") enables IPv4/IPv6 forwarding for exit-node
  # use. Still needs approval in the admin console.
  services.tailscale.useRoutingFeatures = lib.mkForce "both";

  # WireGuard-over-UDP throughput tune for the uplink NIC.
  # https://tailscale.com/s/ethtool-config-udp-gro
  systemd.services.tailscale-udp-gro = {
    description = "UDP GRO forwarding on the tailscale uplink NIC";
    after = [ "sys-subsystem-net-devices-enp6s0.device" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ethtool}/bin/ethtool -K enp6s0 rx-udp-gro-forwarding on rx-gro-list off";
    };
  };

  # --- GPU container runtime + inference -------------------------------------

  # docker for ad-hoc GPU workloads via nvidia-container-toolkit (CDI).
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };
  users.users.eddiezane.extraGroups = [ "docker" ];

  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda; # `acceleration` option was dropped; pick the pkg
    host = "0.0.0.0";           # firewall scopes exposure to tailscale0 (below)
    port = 11434;
    # Flash attention + 8-bit KV cache roughly halve context memory — uncomment
    # to run 14B models with usable context on the 3080's 10GB VRAM.
    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      OLLAMA_CONTEXT_LENGTH = "98304"; # 96k: max that stays 100% on the 3080's 10GB (104k is the hard ceiling; 112k+ spills to CPU and halves tok/s)
      OLLAMA_NO_CLOUD = "1";
    };
  };

  services.open-webui = {
    enable = true;
    # Pinned to 0.9.4 — SearXNG web search broke after this release (still
    # broken on 0.9.6 in nixpkgs-unstable). See the nixpkgs-openwebui flake
    # input; drop the pin once upstream fixes web search.
    package = inputs.nixpkgs-openwebui.legacyPackages.${pkgs.stdenv.hostPlatform.system}.open-webui;
    host = "0.0.0.0";
    port = 8080;
    environment = {
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_AUTH = "True";
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      # Self-hosted web search via the local SearXNG below (no API keys).
      ENABLE_WEB_SEARCH = "True";
      WEB_SEARCH_ENGINE = "searxng";
      SEARXNG_QUERY_URL = "http://127.0.0.1:8888/search?q=<query>";
    };
  };

  # --- SearXNG: web search backend for Open WebUI ----------------------------

  # Localhost-only — Open WebUI queries it in-process, so it never touches the
  # tailnet/firewall. secret_key comes from an off-repo env file (the Nix store
  # is world-readable); create it before the first switch:
  #   sudo mkdir -p /var/lib/searx
  #   echo "SEARX_SECRET_KEY=$(openssl rand -hex 32)" | sudo tee /var/lib/searx/secret.env
  #   sudo chmod 600 /var/lib/searx/secret.env
  services.searx = {
    enable = true;
    redisCreateLocally = true;          # valkey backend for the limiter/cache
    configureUwsgi = true;
    environmentFile = "/var/lib/searx/secret.env";
    uwsgiConfig = {
      http = "127.0.0.1:8888";
      disable-logging = true;
    };
    settings = {
      server = {
        port = 8888;
        bind_address = "127.0.0.1";
        secret_key = "$SEARX_SECRET_KEY";
        limiter = false;                # private single-user instance
      };
      search.formats = [ "html" "json" ]; # json is required for Open WebUI
    };
  };

  # Ollama/Open WebUI reachable on the tailnet only.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 11434 8080 ];
}
