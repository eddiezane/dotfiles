TW() { cd ~/Codez/Twilio/$1; }
_TW() { _files -W ~/Codez/Twilio -/; }
compdef _TW TW

__git_files () { _wanted files expl 'local files' _files }

# function rbenv_check() {
  # global=`rbenv global`
  # current=`rbenv version-name`
  # if [[ "$global" != "$current" ]]; then
    # echo " $current"
  # fi
# }

function mkcd {
  dir="$*";
  mkdir -p "$dir" && cd "$dir";
}

function mdo {
  file="$*";
  open -a /Applications/MacDown.app "$file"
}

function name_dat_tmux {
if [ "$TMUX" ]; then
  if [ "$PWD" != "$OLDPWD" ]; then
    OLDPWD="$PWD";
    tmux rename-window ${PWD##*/};
  fi
fi
}

precmd_functions+='name_dat_tmux'

function ssh {
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

function chrome {
  open -a /Applications/Google\ Chrome.app $@
}

function dnsset() {
  if [ "$1" = "google" ]; then
    sudo networksetup -setdnsservers wi-fi 8.8.8.8 8.8.4.4 2001:4860:4860::8888 2001:4860:4860::8844
  elif [ "$1" = "" ]; then
    sudo networksetup -setdnsservers wi-fi Empty
  fi
}

function dnsget() {
  networksetup -getdnsservers wi-fi
}

function gi() { curl https://www.gitignore.io/api/$@ ;}

_gitignireio_get_command_list() {
  curl -s http://www.gitignore.io/api/list | tr "," "\n"
}

_gitignireio () {
  compset -P '*,'
  compadd -S '' `_gitignireio_get_command_list`
}

compdef _gitignireio gi

