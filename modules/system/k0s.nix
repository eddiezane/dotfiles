{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.k0s;
  serviceName = "k0s${cfg.role}";
  roleArgs = [ cfg.role ]
    ++ optional cfg.singleNode "--single"
    ++ optional (cfg.configFile != null) "--config /etc/k0s/k0s.yaml"
    ++ optional (cfg.tokenFile != null) "--token-file ${cfg.tokenFile}"
    ++ cfg.extraArgs;
  command = [ "${cfg.package}/bin/k0s" "--data-dir" cfg.dataDir ] ++ roleArgs;
in
{
  options.services.k0s = {
    enable = mkEnableOption "the k0s Kubernetes service";

    package = mkOption {
      type = types.package;
      default = pkgs.k0s;
      defaultText = literalExpression "pkgs.k0s";
      description = "The k0s package to run.";
    };

    role = mkOption {
      type = types.enum [ "controller" "worker" ];
      default = "controller";
      description = "The role for this k0s node.";
    };

    singleNode = mkOption {
      type = types.bool;
      default = false;
      description = "Run a controller with the worker enabled on the same node.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/k0s";
      description = "Persistent k0s state directory.";
    };

    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Optional k0s YAML configuration file.";
    };

    tokenFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Path to a worker or controller join token.";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional arguments passed to the k0s role command.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.singleNode || cfg.role == "controller";
        message = "services.k0s.singleNode requires role = \"controller\".";
      }
      {
        assertion = cfg.role != "worker" || cfg.tokenFile != null;
        message = "services.k0s.tokenFile is required for a worker.";
      }
    ];

    environment.systemPackages = [ cfg.package ];

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 root root -"
    ];

    environment.etc = mkIf (cfg.configFile != null) {
      "k0s/k0s.yaml".source = cfg.configFile;
    };

    systemd.services.${serviceName} = {
      description = "k0s ${cfg.role}";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      # k0s launches kubelet and the bundled CNI components from this unit.
      # Unlike a login shell, its generated PATH does not contain host tools
      # such as mount, ip, iptables, and modprobe unless we provide them.
      path = with pkgs; [
        util-linux
        iproute2
        iptables
        kmod
      ];

      serviceConfig = {
        ExecStart = lib.escapeShellArgs command;
        Restart = "on-failure";
        RestartSec = 5;
        KillMode = "process";
      };
    };
  };
}
