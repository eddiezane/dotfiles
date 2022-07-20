ZSH=$HOME/.oh-my-zsh
ZSH_THEME="eddiezane"
CASE_SENSITIVE="true"
DISABLE_AUTO_TITLE="true"
plugins=(git eddiezane kube-ps1)
source $ZSH/oh-my-zsh.sh
unsetopt auto_name_dirs
setopt HIST_IGNORE_SPACE

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

export EDITOR=nvim
export GOPATH=$HOME/Codez/GOPATH

export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache

export NPM_PACKAGES=$HOME/.local/lib/npm
export NODE_PATH="$NPM_PACKAGES/lib/node_modules"

export nvim_path=$(which nvim)
alias vim=$nvim_path

export BROWSER=/usr/bin/google-chrome-stable;
complete -C /usr/bin/aws_completer aws

# Don't double set path
if [[ -z "$THE_PATH_IS_SET" ]]; then
  export PATH=$HOME/.local/bin:$PATH
  export PATH=$GOPATH/bin:$PATH
  [[ -f ~/.asdf/asdf.sh ]] && source ~/.asdf/asdf.sh
  [[ -f /opt/gcloud/google-cloud-sdk/path.zsh.inc ]] && source /opt/gcloud/google-cloud-sdk/path.zsh.inc
  export THE_PATH_IS_SET=true
fi

[[ -f ~/.asdf/completions/asdf.bash ]] && source ~/.asdf/completions/asdf.bash
[[ -f /opt/gcloud/google-cloud-sdk/completion.zsh.inc ]] && source /opt/gcloud/google-cloud-sdk/completion.zsh.inc

alias k="kubectl"
alias kx="kubectx"
alias vu="vim +PlugUpdate +qa"
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

bindkey -s ^f "tmux-sessionizer\n"

# make sure return code is 0
true
