# Steam + Gamescope + Steam-specific udev rules.
{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    # Use gamescope as the per-game session wrapper (HDR, scaling, fps cap).
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # 32-bit GL needed by many proton titles; redundant with hardware.graphics.enable32Bit
  # on the laptop but cheap to assert here.
  hardware.graphics.enable32Bit = true;
}
