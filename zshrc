ZSH=$HOME/.oh-my-zsh
ZSH_THEME="$ZSH_CUSTOM/themes/eddiezane"
CASE_SENSITIVE="true"
DISABLE_AUTO_TITLE="true"
plugins=(git eddiezane)
fpath=(/usr/local/share/zsh-completions $fpath)
source $ZSH/oh-my-zsh.sh
unsetopt auto_name_dirs
setopt HIST_IGNORE_SPACE

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
zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1

if [[ -z "$TMUX" ]]; then
  export BROWSER=open
  export EDITOR=vim
  export GOPATH=/Users/eddiezane/Codez/GOPATH
  export ANDROID_HOME=/Users/eddiezane/Library/Android/sdk
  export PATH=/usr/local/bin:/usr/local/sbin:$GOPATH/bin:/Users/eddiezane/Library/Android/sdk/tools:/Users/eddiezane/Library/Android/sdk/platform-tools:$PATH
  # export HOMEBREW_CASK_OPTS="--appdir=/Applications"
  source ~/.dotfiles/API_KEYS
fi
# if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
# if which jenv > /dev/null; then eval "$(jenv init -)"; fi
# source ~/.nvm/nvm.sh
# source /usr/local/share/zsh-completions/_nvm
# source $(brew --prefix php-version)/php-version.sh && php-version 5

eval "$(thefuck --alias)"

alias :q="exit"
alias :r="ruby"
alias :n="node"
alias :p="python"
alias pypi-deploy="python setup.py sdist bdist_wininst upload"
alias yolo="sudo \$(history | tail -1 | awk \"{\\\$1 = \\\"\\\"; print \\\$0}\")"
alias bu="brew update && brew upgrade"
alias vu="vim +PluginUpdate +qa"
alias bn="babel-node"

ssh-add -l &>/dev/null
if [[ $? == 1 ]]; then
  ssh-add &>/dev/null
fi

# added by travis gem
[ -f /Users/eddiezane/.travis/travis.sh ] && source /Users/eddiezane/.travis/travis.sh

# make sure return code is 0
true
