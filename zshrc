ZSH=$HOME/.oh-my-zsh

ZSH_THEME="eddiezane"

CASE_SENSITIVE="true"

DISABLE_LS_COLORS="true"

plugins=(git eddiezane)

#justin is smart
alias :q="exit"

source $ZSH/oh-my-zsh.sh

#make and cd
function mkcd
{
    dir="$*";
    mkdir -p "$dir" && cd "$dir";
}

#rvm
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

export BROWSER=open
export PATH=$HOME/.rvm/bin:/Applications/android-sdk-macosx/platform-tools:/Applications/android-sdk-macosx/tools:/usr/local/share/npm/bin:$PATH
export EDITOR=vim

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
