#!/bin/bash
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install vim zsh git openssl
sudo chsh eddiezane -s /bin/zsh
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
mkdir ~/.oh-my-zsh/custom/themes
mkdir ~/.oh-my-zsh/custom/plugins
mkdir ~/.oh-my-zsh/custom/plugins/eddiezane
ln -s ~/.dotfiles/vimrc ~/.vimrc
ln -s ~/.dotfiles/zshrc ~/.zshrc
ln -s ~/.dotfiles/gemrc ~/.gemrc
ln -s ~/.dotfiles/eddiezane.zsh-theme ~/.oh-my-zsh/custom/themes/eddiezane.zsh-theme
ln -s ~/.dotfiles/eddiezane.plugin.zsh ~/.oh-my-zsh/custom/plugins/eddiezane/eddiezane.plugins.zsh
curl -#L https://get.rvm.io | bash -s stable --autolibs=3
