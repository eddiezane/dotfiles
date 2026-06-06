{ pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      brlaser  # Brother MFC-L2750DW driver path on NixOS
      brgenml1lpr
      brgenml1cupswrapper
      hplip
    ];
  };

  # Scanner support — Brother MFC + airscan.
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan hplipWithPlugin ];
    brscan4.enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Members of `scanner` group can use sane.
  users.users.eddiezane.extraGroups = [ "scanner" "lp" ];

  environment.systemPackages = with pkgs; [
    simple-scan
  ];
}
