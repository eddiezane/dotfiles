{ pkgs, ... }:

{
  # Ghostty's vim integration is a separate output (pkgs.ghostty.vim) on NixOS,
  # not at $GHOSTTY_RESOURCES_DIR/../vim/vimfiles like upstream lays it out.
  # Expose the path so ~/.config/nvim/lua/plugins/ghostty.lua can find it.
  home.sessionVariables.GHOSTTY_VIM_PLUGIN_DIR = "${pkgs.ghostty.vim}";

  programs.ghostty = {
    enable = true;
    installVimSyntax = true;
    settings = {
      command = "zsh -l";
      window-decoration = false;

      # First entry is primary; second is the emoji fallback.
      font-family = [ "SauceCodePro Nerd Font Mono" "Noto Color Emoji" ];
      font-size = 15;
      window-padding-y = 0;

      theme = "catppuccin-macchiato.conf";
    };
  };

  # Custom theme file — ghostty resolves theme paths under XDG_CONFIG_HOME/ghostty/themes.
  xdg.configFile."ghostty/themes/catppuccin-macchiato.conf".source =
    ./dotfiles/ghostty/themes/catppuccin-macchiato.conf;
}
