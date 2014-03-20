ZSH=$HOME/.oh-my-zsh
ZSH_THEME="$ZSH_CUSTOM/themes/eddiezane"
CASE_SENSITIVE="true"
DISABLE_AUTO_TITLE="true"
plugins=(git eddiezane brew go npm)
source $ZSH/oh-my-zsh.sh
unsetopt auto_name_dirs

if [[ `uname` == "Darwin" ]]; then
  export BROWSER=open
  export EDITOR=vim
  source ~/.dotfiles/API_KEYS
  export GOROOT=/usr/local/Cellar/go/1.2.1/libexec
  export GOPATH=~/.go
  export DOCKER_HOST=tcp://
  export PATH=/usr/local/bin:/usr/local/sbin:$GOPATH/bin:$PATH
  source $(brew --prefix nvm)/nvm.sh
  source /usr/local/share/zsh/site-functions/nvm_bash_completion
else
  export PATH="$HOME/.rbenv/bin:$PATH"
  export PATH=$HOME/.rbenv/bin:/usr/local/go/bin:$PATH
fi

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

alias :q="exit"
alias :r="ruby"
alias :n="node"
alias :p="python"

function mkcd
{
    dir="$*";
    mkdir -p "$dir" && cd "$dir";
}

function name_dat_tmux 
{
  if [ "$TMUX" ]; then
    if [ "$PWD" != "$OLDPWD" ]; then
      OLDPWD="$PWD";
      tmux rename-window ${PWD##*/};
    fi
  fi
}

precmd_functions+='name_dat_tmux'

ssh() {
    if [[ $# == 0 || -z $TMUX ]]; then
        command ssh $@
        return
    fi
    local remote=${${(P)#}#*@*}
    local old_name="$(tmux display-message -p '#W')"
    local renamed=0
    if [[ $remote != -* ]]; then
        renamed=1
        tmux rename-window $remote
    fi
    command ssh $@
    if [[ $renamed == 1 ]]; then
        tmux rename-window "$old_name"
    fi
}

ssh-add -l &>/dev/null
if [[ $? == 1 ]]; then
  ssh-add &>/dev/null
fi
