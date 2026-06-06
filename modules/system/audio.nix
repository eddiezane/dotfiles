{ pkgs, ... }:

{
  # PipeWire + WirePlumber, replacing PulseAudio.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # pavucontrol / pamixer / playerctl live in home-manager (used per-user).
  # wireplumber is pulled in by services.pipewire.wireplumber.enable.
}
