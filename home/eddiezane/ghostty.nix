{ pkgs, config, ... }:

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
      gtk-tabs-location = "bottom";
      gtk-custom-css = "${config.xdg.configHome}/ghostty/tabbar.css";

      # First entry is primary; second is the emoji fallback.
      font-family = [ "SauceCodePro Nerd Font Mono" "Noto Color Emoji" ];
      font-size = 15;
      window-padding-y = 0;

      theme = "catppuccin-macchiato.conf";

      # ~1GB scrollback per surface (default is 10MB). Bytes, not lines, and
      # allocated lazily so a big cap is cheap until actually used.
      scrollback-limit = 1000000000;

      keybind = [
        # `ctrl+a a` sends a literal ctrl+a (mirrors tmux `bind a send-prefix`),
        # so readline jump-to-start-of-line still works.
        "ctrl+a>a=text:\\x01"

        "ctrl+a>up=goto_split:top"
        "ctrl+a>down=goto_split:bottom"
        "ctrl+a>left=goto_split:left"
        "ctrl+a>right=goto_split:right"
        "ctrl+a>o=goto_split:next"

        "ctrl+a>shift+5=new_split:right"
        "ctrl+a>shift+apostrophe=new_split:down"

        "ctrl+a>shift+h=resize_split:left,5"
        "ctrl+a>shift+j=resize_split:down,5"
        "ctrl+a>shift+k=resize_split:up,5"
        "ctrl+a>shift+l=resize_split:right,5"

        "ctrl+a>z=toggle_split_zoom"
        "ctrl+a>x=close_surface"

        "ctrl+a>c=new_tab"
        "ctrl+a>shift+c=new_tab"
        "ctrl+a>n=next_tab"
        "ctrl+a>p=previous_tab"
        "ctrl+a>l=last_tab" # rightmost tab, not MRU
        "ctrl+a>q=toggle_tab_overview"
        "ctrl+a>1=goto_tab:1"
        "ctrl+a>2=goto_tab:2"
        "ctrl+a>3=goto_tab:3"
        "ctrl+a>4=goto_tab:4"
        "ctrl+a>5=goto_tab:5"
        "ctrl+a>6=goto_tab:6"
        "ctrl+a>7=goto_tab:7"
        "ctrl+a>8=goto_tab:8"
        "ctrl+a>9=goto_tab:9"

        "ctrl+a>r=reload_config"
        "ctrl+a>backspace=clear_screen"

        # Scrollback "mode" via a key table (ghostty 1.3+). `ctrl+a [` enters it
        "ctrl+a>left_bracket=activate_key_table:scrollback"
        "ctrl+a>f=start_search"
        "ctrl+a>right_bracket=jump_to_prompt:1"

        "scrollback/j=scroll_page_lines:1"               # line down
        "scrollback/k=scroll_page_lines:-1"              # line up
        "scrollback/ctrl+d=scroll_page_fractional:0.5"   # half-page down
        "scrollback/ctrl+u=scroll_page_fractional:-0.5"  # half-page up
        "scrollback/ctrl+f=scroll_page_down"             # full page down
        "scrollback/ctrl+b=scroll_page_up"               # full page up
        "scrollback/g=scroll_to_top"
        "scrollback/shift+g=scroll_to_bottom"            # G
        "scrollback/p=jump_to_prompt:-1"                 # previous prompt
        "scrollback/n=jump_to_prompt:1"                  # next prompt
        "scrollback/slash=start_search"                  # /
        "scrollback/ctrl+shift+c=copy_to_clipboard:mixed"
        "scrollback/ctrl+shift+v=paste_from_clipboard"
        "scrollback/escape=deactivate_all_key_tables"    # exit mode
        "scrollback/q=deactivate_all_key_tables"         # exit mode
        "scrollback/catch_all=ignore"                    # modal: swallow other keys
      ];
    };
  };

  xdg.configFile."ghostty/tabbar.css".text = ''
    tabbar tabbox {
      min-height: 0;
      margin: 0;
      padding: 0;
    }
    tabbar tabbox tab {
      min-height: 0;
      margin: 0;
      padding: 0;
    }
    tabbar tabbox tab label {
      font-size: 16px;   /* primary height lever now — bigger font = taller bar */
    }
    tabbar tabbox tab button {
      min-height: 16px;
      min-width: 16px;
      margin: 0;
      padding: 0;
    }

    tabbar {
      margin-top: 0px;
      margin-bottom: 0px;
    }
    tabbar tabbox {
      transform: translateY(0px);
    }
  '';

  # Custom theme file — ghostty resolves theme paths under XDG_CONFIG_HOME/ghostty/themes.
  xdg.configFile."ghostty/themes/catppuccin-macchiato.conf".source =
    ./dotfiles/ghostty/themes/catppuccin-macchiato.conf;
}
