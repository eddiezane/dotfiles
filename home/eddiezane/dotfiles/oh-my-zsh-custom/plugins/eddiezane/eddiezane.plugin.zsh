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

function mkcd {
  dir="$*";
  mkdir -p "$dir" && cd "$dir";
}

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
