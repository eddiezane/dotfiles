ZSH=$HOME/.oh-my-zsh

ZSH_THEME="$ZSH_CUSTOM/themes/eddiezane"

CASE_SENSITIVE="true"

DISABLE_AUTO_TITLE="true"

plugins=(git eddiezane brew)

# Justin is smart
alias :q="exit"
alias :r="ruby"
alias :n="node"

source $ZSH/oh-my-zsh.sh

unsetopt auto_name_dirs

# make and cd
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

# Check if on Mac
if [[ `uname` == "Darwin" ]]; then
  export BROWSER=open
  export EDITOR=vim
  source ~/.dotfiles/API_KEYS
  export GOPATH=~/.go
  export PATH=/usr/local/bin:/usr/local/sbin:/usr/local/share/npm/bin:/usr/local/heroku/bin:$GOPATH:/Applications/android-sdk-macosx/platform-tools:/Applications/android-sdk-macosx/tools:$PATH
  if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
else
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
  export PATH=$HOME/.rvm/bin:$PATH
fi

ssh-add -l &>/dev/null
if [[ $? == 1 ]]; then
  ssh-add &>/dev/null
fi
