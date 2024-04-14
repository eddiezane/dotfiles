ZSH=$HOME/.oh-my-zsh
ZSH_THEME="eddiezane"
CASE_SENSITIVE="true"
DISABLE_MAGIC_FUNCTIONS=true
DISABLE_AUTO_TITLE="true"
ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_AUTOSTART_ONCE=false
ZSH_TMUX_AUTOCONNECT=true
plugins=(tmux git eddiezane kube-ps1)
source $ZSH/oh-my-zsh.sh
unsetopt auto_name_dirs
setopt HIST_IGNORE_SPACE
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
export ZSH_TMUX_AUTOSTART=true

# autoload -U compinit && compinit

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
zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1

export nvim_path=$(which nvim)
alias vim=$nvim_path

complete -C /usr/bin/aws_completer aws

# Don't double set path
if [[ -z "$THE_PATH_IS_SET" ]]; then
  [[ -f ~/.asdf/asdf.sh ]] && source ~/.asdf/asdf.sh
  [[ -f /opt/gcloud/google-cloud-sdk/path.zsh.inc ]] && source /opt/gcloud/google-cloud-sdk/path.zsh.inc
  export THE_PATH_IS_SET=true
fi

[[ -f ~/.asdf/completions/asdf.bash ]] && source ~/.asdf/completions/asdf.bash
[[ -f /opt/gcloud/google-cloud-sdk/completion.zsh.inc ]] && source /opt/gcloud/google-cloud-sdk/completion.zsh.inc
[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f ~/.config/op/plugins.sh ]] && source ~/.config/op/plugins.sh

alias k="kubectl"
alias kx="kubectx"
alias vu="vim +PlugUpdate +qa"

if [[ "$XDG_SESSION_TYPE" == "wayland" ]]
then
  alias pbcopy='wl-copy -n -p'
  alias pbpaste='wl-paste -p'
else
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

bindkey -s ^f "tmux-sessionizer\n"

# make sure return code is 0
true
