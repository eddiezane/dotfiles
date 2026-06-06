# zsh + oh-my-zsh with the custom theme and plugin in place.
#
# NixOS doesn't ship the "stock" oh-my-zsh layout under $ZSH=$HOME/.oh-my-zsh.
# home-manager's programs.zsh.oh-my-zsh sets ZSH to the nix store path. To keep
# the existing $ZSH_CUSTOM = $HOME/.oh-my-zsh-custom layout (with the eddiezane
# theme + plugin) working unchanged, we symlink the custom dir into $HOME.
{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    oh-my-zsh
    zsh
    bat
    eza
    # Rust system-wide (no rustup; nightly/per-project goes through devShells + rust-overlay).
    rustc
    cargo
    rustfmt
    clippy
    # GCloud as a single nix package (gke-auth plugin available via withExtraComponents).
    google-cloud-sdk
    # fzf, ripgrep, fd, jq, yq-go, direnv -> packages.nix (used by many things).
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # Keep .zshrc / .zprofile / .zshenv in $HOME (the default that oh-my-zsh
    # expects). HM's future default will move them to
    # $XDG_CONFIG_HOME/zsh; we pin the legacy location explicitly.
    dotDir = config.home.homeDirectory;
    history = {
      size = 1000000000;
      save = 1000000000;
      ignoreSpace = true;
    };

    oh-my-zsh = {
      enable = true;
      theme = "eddiezane";
      plugins = [ "git" "eddiezane" "kube-ps1" ];
      # home-manager writes this as a single-quoted string into .zshrc, so it
      # MUST be a literal path (not '$HOME/...'). Evaluate at build time.
      custom = "${config.home.homeDirectory}/.oh-my-zsh-custom";
    };

    # Carries over the relevant bits of the old ~/.zprofile. We don't replicate
    # `source /etc/profile` (NixOS handles that itself) or the gcloud path.zsh.inc
    # (not installed via nix yet — uncomment when you bring it in).
    profileExtra = ''
      # [[ -f /opt/gcloud/google-cloud-sdk/path.zsh.inc ]] && source /opt/gcloud/google-cloud-sdk/path.zsh.inc
    '';

    initContent = ''
      # Match the original ~/.zshrc setup.
      typeset -U path
      DISABLE_MAGIC_FUNCTIONS=true
      DISABLE_AUTO_TITLE="true"
      CASE_SENSITIVE="true"
      ZSH_TMUX_AUTOSTART=true
      ZSH_TMUX_AUTOSTART_ONCE=false
      ZSH_TMUX_AUTOCONNECT=true

      unsetopt auto_name_dirs
      setopt HIST_IGNORE_SPACE

      # kube-ps1 tuning (off by default; toggle with `kubeon`)
      export KUBE_PS1_ENABLED=off
      function kube_cut_ns() {
        if [[ $1 == "default" ]]; then
          echo ""
        else
          echo " $1"
        fi
      }
      export KUBE_PS1_SYMBOL_ENABLE=false
      export KUBE_PS1_PREFIX=""
      export KUBE_PS1_SUFFIX=""
      export KUBE_PS1_DIVIDER=""
      export KUBE_PS1_NAMESPACE_FUNCTION=kube_cut_ns

      bindkey -v
      bindkey '^P' up-history
      bindkey '^N' down-history
      bindkey '^?' backward-delete-char
      bindkey '^h' backward-delete-char
      bindkey '^w' backward-kill-word
      bindkey '^r' history-incremental-search-backward
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd v edit-command-line
      bindkey -M viins '^A' vi-beginning-of-line
      bindkey -M viins '^E' vi-end-of-line
      # Register the eddiezane theme's vi-mode prompt widgets.
      zle -N zle-line-init
      zle -N zle-keymap-select
      export KEYTIMEOUT=1

      if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        alias pbcopy='wl-copy -n -p'
        alias pbpaste='wl-paste -p'
      else
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
      fi

      # 1Password shell plugins (sourced when `op` is set up; harmless if absent).
      [[ -f ~/.config/op/plugins.sh ]] && source ~/.config/op/plugins.sh

      true
    '';

    shellAliases = {
      k = "kubectl";
      kx = "kubectx";
      vu = "vim +PlugUpdate +qa";
      vim = "nvim";
    };
  };

  # Carry the custom theme + plugin to ~/.oh-my-zsh-custom.
  home.file.".oh-my-zsh-custom" = {
    source = ./dotfiles/oh-my-zsh-custom;
    recursive = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
