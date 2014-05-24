#!/bin/bash

# make the hard links so we don't have to move them back and forth to commit/push/pull
ln .vimrc ~/
ln .bashrc ~/

#use the new .bashrc
source ~/.bashrc

#Kill CapsLock
(dumpkeys | grep keymaps; echo "keycode 58 = Escape") | loadkeys


#Don't do any fancy network stuff if simple is active
if [ "$1" = "s" ];
then
	exit 0
fi

#Try to get Vundle
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim 2>&1 
#git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim 2>&1 || { echo >&2 "Git not installed, attempting to install..."; sudo apt-get -y install git-core; git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim }

#Install plugins
vim +PluginInstall +qall

#Install bro because I'm a noob
sudo apt-get install rubygems
gem install bropages

#install most and set as default more, should color man pages and stuff
apt-get install most && update-alternatives --set pager /usr/bin/most


#Go through all of the color schemes for popular terminal emulators and try to copy the correct files to the correct places
#Those that don't match the current terminal emulator should simply fail. I may pipe the errors to dev/null later
#iTerm2 needs to be set manually

#xfce-terminal
cp terminalrc ~/.config/Terminal/terminalrc

#gnome
rake set scheme=solarized_dark

#xterm
cp .Xresources ~

#Konsole
cp SolarizedDark.colorscheme ~/.kde/share/apps/konsole

