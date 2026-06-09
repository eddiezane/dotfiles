# tmux — nix-native programs.tmux. The big body of `set -g ...` lines lives in
# `extraConfig` to keep it easy to diff against the upstream tmux.conf;
# structured options that home-manager exposes (prefix, mouse, baseIndex, etc.)
# are promoted into attrs.
{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    baseIndex = 1;
    escapeTime = 10;
    focusEvents = true;
    historyLimit = 1000000000;
    keyMode = "vi";
    sensibleOnTop = false;
    terminal = "tmux-256color";

    extraConfig = ''
      # True-color in xterm-compatible terminals.
      set-option -sa terminal-features ',xterm-256color:RGB'

      # Send the prefix through with `prefix a`.
      bind a send-prefix

      # Reload the config.
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded tmux.conf"

      bind BSpace clear-history

      set -g pane-base-index 1
      # Name each window after its cwd basename. Replaces the old name_dat_tmux
      # zsh precmd hook with a tmux-native, shell-agnostic equivalent (b: = basename).
      set -g allow-rename off
      set -g automatic-rename on
      set -g automatic-rename-format '#{b:pane_current_path}'

      # Status bar content
      set -g status-interval 5
      set -g status-left '#(if [[ -n $SSH_CLIENT ]]; then echo "🔌 "; fi)#[fg=colour245]#S '
      set -g status-right '#[fg=colour207] @eddiezane '
      set -g status-right-length 100

      # Status bar styling
      set -g status-style bg=colour235,fg=colour7
      set -g window-status-current-style fg=colour207

      # Show activity in other windows
      set -g monitor-activity on
      set -g window-status-activity-style bold

      # Messages
      set -g display-time 3000
      set -g message-style bg=colour207,fg=black

      # Panes
      set -g pane-border-style fg=colour8
      set -g pane-active-border-style fg=colour7

      # New window same dir
      bind C new-window -c "#{pane_current_path}"
      bind S attach -c "#{pane_current_path}"

      # Window
      bind-key / command-prompt -p "swap with target:" "swap-window -t ':%%'"

      # Clock
      set -g clock-mode-style 12
      set -g clock-mode-colour colour207

      # vi-mode copy bindings
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi y send -X copy-selection

      bind-key -r J resize-pane -D 5
      bind-key -r K resize-pane -U 5
      bind-key -r H resize-pane -L 5
      bind-key -r L resize-pane -R 5

      bind-key Up    select-pane -U
      bind-key Down  select-pane -D
      bind-key Left  select-pane -L
      bind-key Right select-pane -R
    '';
  };
}
