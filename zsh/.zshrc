ZSH=$HOME/.oh-my-zsh
ZSH_THEME="eddiezane"
CASE_SENSITIVE="true"
DISABLE_AUTO_TITLE="true"
plugins=(git eddiezane golang docker)
source $ZSH/oh-my-zsh.sh
unsetopt auto_name_dirs
setopt HIST_IGNORE_SPACE

autoload -U compinit && compinit

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

export EDITOR=vim
export GOPATH=/home/eddiezane/Codez/GOPATH

# Don't double set path in tmux
if [[ -z "$TMUX" ]]; then
  export PATH=/usr/local/bin:/usr/local/sbin:$GOPATH/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH

  if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
  fi
fi

[ -f ~/.dotfiles/secrets ] && source ~/.dotfiles/secrets

export nvim_path=$(which nvim)
alias vim=$nvim_path
alias ovim=$HOMEBREW_PREFIX/bin/vim

alias :q="exit"
alias :r="ruby"
alias :n="node"
alias :p="python"
alias k="kubectl"
alias yolo="sudo \$(history | tail -1 | awk \"{\\\$1 = \\\"\\\"; print \\\$0}\")"
alias bu="sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade && brew upgrade"
alias vu="vim +PlugUpdate +qa"
alias buvu="bu && vu"

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

ssh-add -l &>/dev/null
if [[ $? == 1 ]]; then
  ssh-add &>/dev/null
fi

# make sure return code is 0
true
