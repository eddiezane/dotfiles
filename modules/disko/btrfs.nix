# Disk layout: ESP + BTRFS with subvolumes (including a swapfile). No LUKS.
#
# Stack:
#   /dev/<disk>
#     ├── p1  ESP (vfat, mounted at /boot)
#     └── p2  BTRFS
#              ├── @           /
#              ├── @home       /home
#              ├── @nix        /nix
#              ├── @log        /var/log
#              └── @swap       /swap   (NoCoW)
#                               └── swapfile (size = swapSize)
#
# Plain (unencrypted) sibling of luks-btrfs.nix, for headless hosts that must
# boot without a passphrase prompt. No hibernation, so no `resume_offset=`
# wiring — the swapfile is overflow only (zram handles the common case).
#
# Parameters (via `_module.args.diskoArgs`):
#   disk     : block device path — prefer /dev/disk/by-id/* on multi-disk boxes.
#   swapSize : swapfile size string, e.g. "16G".
#   espSize  : ESP size, default "1G".
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
          root = {
            size = "100%";
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
                  # `swap` is declared. No resume_offset wiring — this host
                  # doesn't hibernate.
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
}
