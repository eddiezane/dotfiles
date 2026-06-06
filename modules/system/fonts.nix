{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      source-code-pro
      ubuntu-classic
      font-awesome
      # SauceCodePro Nerd Font (referenced by waybar/wofi/ghostty)
      nerd-fonts.sauce-code-pro
      nerd-fonts.symbols-only
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "SauceCodePro Nerd Font Mono" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
