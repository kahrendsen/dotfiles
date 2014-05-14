#!/bin/bash

# make the hard links so we don't have to move them back and forth to commit/push/pull
ln .vimrc ~/
ln .bashrc ~/

#reload bash to use the new .bashrc
source ~/.bashrc

#Kill CapsLock
(dumpkeys | grep keymaps; echo "keycode 58 = Escape") | loadkeys

#Don't do any fancy network stuff if simple is active
if [ "$1" = "s" ];
then
	exit 0
fi

#Try to get Vundle
#git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim 2>&1 || { echo >&2 "Git not installed, attempting to install..."; sudo apt-get -y install git-core; git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim }

#Install plugins
vim +PluginInstall +qall

#Install bro because I'm a noob
sudo apt-get install rubygems
gem install bropages

