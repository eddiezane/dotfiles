ZSH=$HOME/.oh-my-zsh

ZSH_THEME="$ZSH_CUSTOM/themes/eddiezane"

CASE_SENSITIVE="true"

# DISABLE_LS_COLORS="true"

DISABLE_AUTO_TITLE="true"

plugins=(git eddiezane)

# Justin is smart
alias :q="exit"
alias :r="ruby"

source $ZSH/oh-my-zsh.sh

# make and cd
function mkcd
{
    dir="$*";
    mkdir -p "$dir" && cd "$dir";
}

# Check if on Mac
if [[ `uname` == "Darwin" ]]; then
  export BROWSER=open
  export EDITOR=vim
  export PATH=/usr/local/bin:/usr/local/share/npm/bin:/usr/local/heroku/bin:/Applications/android-sdk-macosx/platform-tools:/Applications/android-sdk-macosx/tools:$PATH
  if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
else
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
  export PATH=$HOME/.rvm/bin:$PATH
fi

