#!/bin/sh

installMenu() {
  echo "Super Awesome Install Menu"
  echo "\t 1. Git"
  echo "\t 2. Vim"
  echo "\t 3. Zsh"
  echo "\t 4. Tmux"
  echo "\t 5. RVM"
  echo "\t 6. Symlink All"
  echo "\t 9. All"
  echo "\t q. Quit"
}

installGit() {
  sudo apt-get install git
}

installVim() {
  sudo apt-get install vim
  git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
  rm ~/.vimrc
  ln -s ~/.dotfiles/vimrc ~/.vimrc
}

installZsh() {
  sudo apt-get install zsh
  sudo chsh $USER -s /bin/zsh
  git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
  mkdir ~/.oh-my-zsh/custom/themes
  mkdir ~/.oh-my-zsh/custom/plugins
  mkdir ~/.oh-my-zsh/custom/plugins/eddiezane
  rm ~/.zshrc
  ln -s ~/.dotfiles/zshrc ~/.zshrc
  ln -s ~/.dotfiles/eddiezane.zsh-theme ~/.oh-my-zsh/custom/themes/eddiezane.zsh-theme
  ln -s ~/.dotfiles/eddiezane.plugin.zsh ~/.oh-my-zsh/custom/plugins/eddiezane/eddiezane.plugins.zsh
}

installTmux() {
  sudo apt-get install tmux
  rm ~/.tmux.conf
  ln -s ~/.dotfiles/tmux.conf ~/.tmux.conf
}

installRVM() {
  sudo apt-get install openssl
  curl -#L https://get.rvm.io | bash -s stable --autolibs=3
  ln -s ~/.dotfiles/gemrc ~/.gemrc
}

symlinkAll() {
  rm ~/.vimrc
  rm ~/.zshrc
  rm ~/.tmux.conf
  rm ~/.oh-my-zsh/custom/theme/eddiezane.zsh-theme
  rm ~/.oh-my-zsh/custom/plugins/eddiezane/eddiezane.plugins.zsh
  rm ~/.gemrc
  ln -s ~/.dotfiles/vimrc ~/.vimrc
  ln -s ~/.dotfiles/zshrc ~/.zshrc
  ln -s ~/.dotfiles/eddiezane.zsh-theme ~/.oh-my-zsh/custom/themes/eddiezane.zsh-theme
  ln -s ~/.dotfiles/eddiezane.plugin.zsh ~/.oh-my-zsh/custom/plugins/eddiezane/eddiezane.plugins.zsh
  ln -s ~/.dotfiles/tmux.conf ~/.tmux.conf
  ln -s ~/.dotfiles/gemrc ~/.gemrc
}

installAll() {
  installGit
  installVim
  installZsh
  installTmux
  installRVM
}

sudo apt-get update
sudo apt-get upgrade
clear

installMenu

while true
do
  read input
  case $input in
    1) installGit;;
    2) installVim;;
    3) installZsh;;
    4) installTmux;;
    5) installRVM;;
    6) symlinkAll;;
    9) installAll;;
    q) break;;
  esac
  installMenu
done

