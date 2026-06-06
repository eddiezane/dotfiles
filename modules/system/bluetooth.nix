{ pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true; # battery levels in blueman
        FastConnectable = true;
      };
    };
  };

  services.blueman.enable = true;
}
