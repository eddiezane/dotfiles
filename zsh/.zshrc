ZSH=$HOME/.oh-my-zsh
ZSH_THEME="eddiezane"
# ZSH_THEME="$ZSH_CUSTOM/themes/eddiezane"
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

if [[ -z "$TMUX" ]]; then
  # export BROWSER=open
  export EDITOR=vim
  export GOPATH=/home/eddiezane/Codez/GOPATH
  # export ANDROID_HOME=/Users/eddiezane/Library/Android/sdk
  export PATH=/usr/local/bin:/usr/local/sbin:/usr/local/go/bin:$PATH
  # export PATH=/usr/local/bin:/usr/local/sbin:$GOPATH/bin:/usr/local/go/bin:$PATH
  # export PATH=/usr/local/bin:/usr/local/sbin:$GOPATH/bin:/Users/eddiezane/Library/Android/sdk/tools/bin:/Users/eddiezane/Library/Android/sdk/platform-tools:$PATH
  # [ -f /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc ] && source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
  # [ -f /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc ] && source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
fi

# [ -f /Users/eddiezane/.travis/travis.sh ] && source /Users/eddiezane/.travis/travis.sh
[ -f ~/.dotfiles/secrets ] && source ~/.dotfiles/secrets
# [ -f /usr/local/share/zsh/site-functions/_tmuxinator ] && source /usr/local/share/zsh/site-functions/_tmuxinator
# [ -f /usr/local/opt/asdf/asdf.sh ] && source /usr/local/opt/asdf/asdf.sh
# [ -f /usr/local/etc/bash_completion.d/asdf.bash ] && source /usr/local/etc/bash_completion.d/asdf.bash


# if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
# if which jenv > /dev/null; then eval "$(jenv init -)"; fi
# source ~/.nvm/nvm.sh
# source /usr/local/share/zsh-completions/_nvm
# source $(brew --prefix php-version)/php-version.sh && php-version 5

if [ ! -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
  export PATH=/home/linuxbrew/.linuxbrew/bin::$PATH
fi

alias :q="exit"
alias :r="ruby"
alias :n="node"
alias :p="python"
alias k="kubectl"
alias pypi-deploy="python setup.py sdist bdist_wininst upload"
alias yolo="sudo \$(history | tail -1 | awk \"{\\\$1 = \\\"\\\"; print \\\$0}\")"
# alias bu="brew update && brew upgrade"
alias bu="sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade"
alias vu="vim +PluginUpdate +qa"
alias buvu="bu && vu"

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

ssh-add -l &>/dev/null
if [[ $? == 1 ]]; then
  ssh-add &>/dev/null
fi

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

# make sure return code is 0
true
