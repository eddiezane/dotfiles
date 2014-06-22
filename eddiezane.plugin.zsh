DDev() { cd ~/Dropbox/Development/$1; }
_DDev() { _files -W ~/Dropbox/Development -/; }
compdef _DDev DDev

SG() { cd ~/Codez/SendGrid/$1; }
_SG() { _files -W ~/Codez/SendGrid -/; }
compdef _SG SG

__git_files () { _wanted files expl 'local files' _files }

function rbenv_check() {
  global=`rbenv global`
  current=`rbenv version-name`
  if [[ "$global" != "$current" ]]; then
    echo " $current"
  fi
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

function gi() { curl http://www.gitignore.io/api/$@ ;}

_gitignireio_get_command_list() {
  curl -s http://www.gitignore.io/api/list | tr "," "\n"
}

_gitignireio () {
  compset -P '*,'
  compadd -S '' `_gitignireio_get_command_list`
}

compdef _gitignireio gi

