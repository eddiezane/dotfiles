ZSH=$HOME/.oh-my-zsh
ZSH_THEME="eddiezane"
CASE_SENSITIVE="true"
DISABLE_AUTO_TITLE="true"
plugins=(git eddiezane kube-ps1)
# FPATH must be set before calling compinit. Sourcing oh-my-zsh calls it.
FPATH=/opt/linuxbrew/share/zsh/site-functions:$FPATH
source $ZSH/oh-my-zsh.sh
unsetopt auto_name_dirs
setopt HIST_IGNORE_SPACE

# autoload -U compinit && compinit

export KUBE_PS1_ENABLED=off

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

export nvim_path=$(which nvim)
alias vim=$nvim_path

if [[ -f /etc/arch-release ]]; then
  export BROWSER=/usr/bin/google-chrome-stable;
  alias bu="sudo yay -Syu"
  complete -C /usr/bin/aws_completer aws
elif [[ `uname` == "Darwin" ]]; then
  alias bu="brew upgrade"
  export GOPROXY=direct
fi

# Don't double set path in tmux
if [[ -z "$TMUX" ]]; then
  export PATH=/usr/local/bin:/usr/local/sbin:$PATH

  if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
  elif [[ -f /opt/linuxbrew/bin/brew ]]; then
    eval $(/opt/linuxbrew/bin/brew shellenv)
  elif [[ -f /usr/local/bin/brew ]]; then
    eval $(/usr/local/bin/brew shellenv)
  fi
fi

[[ -f ~/.dotfiles/secrets ]] && source ~/.dotfiles/secrets
[[ -f ~/.asdf/asdf.sh ]] && source ~/.asdf/asdf.sh
[[ -f ~/.asdf/completions/asdf.bash ]] && source ~/.asdf/completions/asdf.bash
[[ -f /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc ]] && source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
[[ -f /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc ]] && source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc

alias ovim=$HOMEBREW_PREFIX/bin/vim

alias :q="exit"
alias :r="ruby"
alias :n="node"
alias :p="python"
alias k="kubectl"
alias kx="kubectx"
alias yolo="sudo \$(history | tail -1 | awk \"{\\\$1 = \\\"\\\"; print \\\$0}\")"
alias vu="vim +PlugUpdate +qa"
alias buvu="bu && vu"

if [[ `uname` == 'Linux' ]]; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

ssh-add -l &>/dev/null
if [[ $? == 1 ]]; then
  ssh-add &>/dev/null
fi

# make sure return code is 0
true
