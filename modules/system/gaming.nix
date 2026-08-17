# Gaming runtime for the Framework laptop: Steam/Proton, Gamescope, and
# diagnostic/configuration tools commonly needed by native and Proton titles.
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

  # Lets supported games request a performance-oriented CPU/IO scheduling
  # profile. Steam titles can enable it with `gamemoderun %command%`.
  programs.gamemode.enable = true;

  # ProtonUp-Qt installs compatibility tools such as Proton-GE into Steam's
  # compatibility-tools directory; Protontricks is useful for per-prefix
  # fixes. MangoHud is enabled per game with `mangohud %command%`.
  environment.systemPackages = with pkgs; [
    mangohud
    protontricks
    protonup-qt
  ];

  # 32-bit GL needed by many proton titles; redundant with hardware.graphics.enable32Bit
  # on the laptop but cheap to assert here.
  hardware.graphics.enable32Bit = true;
}
