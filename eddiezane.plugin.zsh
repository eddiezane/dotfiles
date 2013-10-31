DDev() { cd ~/Dropbox/Development/$1; }
_DDev() { _files -W ~/Dropbox/Development -/; }
compdef _DDev DDev

SG() { cd ~/Code/SendGrid/$1; }
_SG() { _files -W ~/Code/SendGrid -/; }
compdef _SG SG

__git_files () { _wanted files expl 'local files' _files }

function rbenv_check() {
  global=`rbenv global`
  current=`rbenv version-name`
  if [[ "$global" != "$current" ]]; then
    echo " $current"
  fi
}
