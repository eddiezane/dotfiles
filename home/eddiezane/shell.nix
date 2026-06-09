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
      # Prompt is handled by starship now (see programs.starship below); the old
      # eddiezane theme has been removed. To revert, restore it from git history
      # and drop the programs.starship block.
      theme = "";
      plugins = [ "git" "eddiezane" ];
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
      DISABLE_AUTO_TITLE="true"

      unsetopt auto_name_dirs

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

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      # \${...} is an escaped literal ${...} (starship custom-module ref), not Nix interpolation.
      format = " $kubernetes$nix_shell$direnv$hostname$directory$git_branch\${custom.gitstate} ";
      right_format = "$jobs$character";

      directory = {
        truncation_length = 2;       # like %2~
        truncate_to_repo = false;
        truncation_symbol = "";
        style = "207";
        format = "[$path]($style)";  # no trailing space: git bracket abuts the path, as before
      };

      # vi-mode: nothing in insert mode, "[ NORMAL]" in command mode (matches old RPROMPT).
      character = {
        success_symbol = "";
        error_symbol = "";
        vimcmd_symbol = "[ NORMAL](bold yellow)";
      };

      # old ssh_check: just the plug when on an SSH connection.
      hostname = {
        ssh_only = true;
        ssh_symbol = "🔌 ";
        format = "[$ssh_symbol]($style) ";
        style = "207";
      };

      git_branch = {
        symbol = "";
        format = "[\\[$branch]($style)";  # opening "[branch"; custom.gitstate closes the bracket
        style = "bold white";
      };

      custom.gitstate = {
        when = "git rev-parse --is-inside-work-tree";
        shell = [ "bash" "--noprofile" "--norc" ];
        command = ''
          status="$(git status --porcelain 2>/dev/null)"
          if [ -z "$status" ]; then printf '🌞'
          elif grep -q '^[^?]' <<<"$status"; then printf '🌂'; fi
        '';
        format = "[( $output)\\]]($style)";  # no trailing space; the single separator comes from the main format
        style = "bold white";
      };

      # manual `nix develop` / `nix-shell` (sets IN_NIX_SHELL).
      nix_shell = {
        symbol = "❄ ";
        format = "[$symbol$name]($style) ";
        style = "cyan";
      };

      # nix-direnv / direnv-loaded envs. May fire alongside nix_shell in flake
      # dirs (double ❄) — disable whichever you don't want once you see it live.
      direnv = {
        disabled = false;
        format = "[$symbol]($style) ";
        symbol = "❄ ";
        style = "cyan";
        allowed_msg = "";
        not_allowed_msg = "";
        denied_msg = "";
        loaded_msg = "";
        unloaded_msg = "";
      };

      # old RPROMPT job count: [n] when >=1 background job.
      jobs = {
        symbol = "";
        number_threshold = 1;
        format = "[\\[$number\\]]($style) ";
        style = "207";
      };

      # kube context was off by default (KUBE_PS1_ENABLED=off); leave disabled,
      # flip to false to bring it back.
      kubernetes = {
        disabled = true;
        format = "[$context( \\($namespace\\))]($style) ";
        style = "207";
      };
    };
  };
}
