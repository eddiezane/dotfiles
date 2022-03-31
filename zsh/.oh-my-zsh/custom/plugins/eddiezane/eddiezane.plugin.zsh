kk() { 
  if [[ $1 == "" ]]
  then
    cd ~/Codez/kubernetes/kubernetes;
  elif [[ $1 == "kubectl" ]]
  then
    cd ~/Codez/kubernetes/kubernetes/staging/src/k8s.io/kubectl;
  else
    cd ~/Codez/kubernetes/$1;
  fi
}
_kk() { _files -W ~/Codez/kubernetes -/; }
compdef _kk kk

sigstore() {
  cd ~/Codez/sigstore/$1;
}
_sigstore() { _files -W ~/Codez/sigstore -/; }
compdef _sigstore sigstore

function gs_check() {
  if [[ -n ${GEM_HOME} ]]; then
    echo " GS"
  fi
}

function gopath_check() {
  case $PWD/ in
    */GOPATH/*) echo " GP"
  esac
}

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

function ssh_check {
  if [[ -n ${SSH_CLIENT} ]]; then
    echo "🔌 "
  fi
}

function flushdns {
  sudo killall -HUP mDNSResponder
}
