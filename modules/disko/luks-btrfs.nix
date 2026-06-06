# Disk layout: ESP + LUKS -> BTRFS with subvolumes (including a swapfile).
#
# Stack:
#   /dev/<disk>
#     ├── p1  ESP (vfat, mounted at /boot)
#     └── p2  LUKS  →  cryptroot  →  BTRFS
#                                      ├── @           /
#                                      ├── @home       /home
#                                      ├── @nix        /nix
#                                      ├── @log        /var/log
#                                      └── @swap       /swap   (NoCoW)
#                                                       └── swapfile (size = swapSize)
#
# LVM is gone — BTRFS subvolumes do the volume-pooling job, and the swapfile
# lives in a NoCoW subvolume so it works correctly with hibernation. disko
# generates the correct `resume_offset=` kernel parameter automatically.
#
# `.snapshots` subvolumes (under @ and @home) are NOT created here; snapper
# creates them on first activation when modules/system/snapshots.nix is enabled.
#
# Parameters (passed via `_module.args.diskoArgs` in the host module):
#   disk         : block device path, e.g. "/dev/nvme0n1"
#   swapSize     : swapfile size string, e.g. "96G". Must be >= RAM for hibernate.
#   espSize      : ESP size, default "1G"
#   passwordFile : optional path to a file containing the LUKS passphrase. When
#                  set, disko reads it instead of prompting on /dev/tty.
{ diskoArgs, ... }:

let
  disk = diskoArgs.disk;
  swapSize = diskoArgs.swapSize;
  espSize = diskoArgs.espSize or "1G";
in {
  disko.devices = {
    disk.main = {
      type = "disk";
      device = disk;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            size = espSize;
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              extraOpenArgs = [ "--allow-discards" ];
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
              };
              passwordFile = diskoArgs.passwordFile or null;
              content = {
                type = "btrfs";
                extraArgs = [ "-L" "nixos" "-f" ];
                subvolumes = {
                  "/@" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd:1" "noatime" "ssd" ];
                  };
                  "/@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd:1" "noatime" "ssd" ];
                  };
                  "/@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd:1" "noatime" "ssd" ];
                  };
                  "/@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd:1" "noatime" "ssd" ];
                  };
                  "/@swap" = {
                    # NoCoW + no compression: required for swapfiles. disko sets
                    # +C and "no compression" on the subvol automatically when
                    # `swap` is declared.
                    #
                    # Hibernation resume offset is NOT auto-wired here — set
                    # `boot.resumeDevice` to the LUKS device and pass
                    # `resume_offset=<N>` in kernelParams. Compute N once with:
                    #   sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
                    # Then commit that to hosts/<host>/default.nix.
                    mountpoint = "/swap";
                    swap.swapfile.size = swapSize;
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
