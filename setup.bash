#!/bin/bash

#A setup file for making the environment the way I like it. I kinda-sorta made it cross-platform-ish.
#I hope for it to work on all flavors of Debian, Fedora, and OSX/Darwin.
#Terminal emulator is an issue as well, this should hopefully support Gnome shell, Konsole, Xfce terminal, xterm, and iTerm2.
#Will probably never add Gentoo or Slackware
echo "Starting setup script..."

#Record this script's directory
#Apparently the thing dirname spits out is sometimes relative, so be careful
dir=$(dirname $0)
echo "Working directory for this script is $dir"

#Make sure the current folder gives us the right permissions
echo "Changing permissions of working directory..."
sudo chmod 744 $dir/* && echo 'Successfully changed permissions' || echo 'Failed to change permissions!'

# make the hard links so we don't have to move them back and forth to commit/push/pull
echo 'Linking dotfiles in home...'
ln -i "$(dirname "$0")"/.vimrc ~/ \
    || (echo "Hard link of .vimrc failed, falling back to soft link" && ln -s "$(dirname "$0")"/.vimrc ~/)
ln -i $(dirname $0)/.bashrc ~/ \
    || (echo "Hard link of .bashrc failed, falling back to soft link" && ln -s "$(dirname "$0")"/.bashrc ~/)
ln -i $dir/.common.sh ~/ \
    || (echo "Hard link of .common.sh failed, falling back to soft link" && ln -s "$(dirname "$0")"/.common.sh ~/)
ln -i $dir/.zshrc ~/ \
    || (echo "Hard link of .zshrc failed, falling back to soft link" && ln -s "$(dirname "$0")"/.zshrc ~/)

echo 'Finished linking dotfiles'


#use the new .bashrc
source ~/.bashrc

#copy git stuff
echo 'Copying git stuff...'
cp $(dirname $0)/git-prompt.sh ~
cp $(dirname $0)/git-completion.bash ~
echo 'Finished copying git stuff'

#make sure bashrc loads in login shells too
grep "source ~/.bashrc" ~/.bash_profile &> /dev/null || (echo "source ~/.bashrc" >> ~/.bash_profile && echo 'Added "source ~/.bashrc" to ~/.bash_profile')

###################################################################################################

#Don't do any fancy network stuff if simple is active
if [ "$1" = "-s" ];
then
    echo "Simple is active, exiting setup"
	exit 0
fi

#Go through all of the color schemes for popular terminal emulators and try to copy the correct files to the correct places
#Those that don't match the current terminal emulator should simply fail. I may pipe the errors to dev/null later
#iTerm2 needs to be set manually, the file to import is in the git repo

#I don't think these work very well so I'll come back to this later

#xfce-terminal
#cp -i terminalrc ~/.config/Terminal/terminalrc || echo "Not Xfce"

#gnome
#rake set scheme=solarized_dark &> /dev/null || echo "Not Gnome"

#xterm
#(which xterm && cp .Xresources && xrdb -merge ~/.Xresources~) &> /dev/null || echo "Not xterm"

#Konsole
#cp SolarizedDark.colorscheme ~/.kde/share/apps/konsole &> /dev/null || echo "Not Konsole"

#note how much space we have now so we know how much we used when we're through
#hopefully this helps figure out if I can use this on, say, a Raspberry Pi
usedSpaceStart=$( ( (df --total 2> /dev/null | grep total) || (df 2> /dev/null | grep disk1) ) | awk 'END{print $3;}')

#major package managers: apt - Debian, yum - Fedora, homebrew - OSX, pacman - Arch

echo "Trying to find package manager..."

installer="ERROR" # somehow didnt have aptitude or yum and we're not on OSX, or something failed
upgrade="ERROR"

#Fedora
which yum &> /dev/null && installer="sudo yum -y install" \
    && upgrade="sudo yum -y upgrade" \
    && echo "Found yum for installer"

#Debian
which apt &> /dev/null \
    && installer="sudo apt -y install" \
    && upgrade="sudo apt -y upgrade" \
    && sudo apt update \
    && echo "Found apt for installer"

#OSX
uname | grep -i darwin &> /dev/null \
    && (which brew || (ruby "$(dirname "$0")"/homebrew_install.rb && echo "Installed homebrew")) \
    && installer="brew install" \
    && upgrade="brew upgrade" \
    && brew update \
    && zsh $dir/di-xquartz.sh \
    && echo "Found brew for installer"

#Arch
which pacman &>/dev/null \
    && installer="sudo pacman -S --noconfirm " \
    && upgrade="sudo pacman -Syu" \
    && echo "Found pacman for installer"

if [ "$installer" == "ERROR" ] || [ "$upgrade" == "ERROR" ]; 
    then
        echo 'Could not find an installer, exiting setup';
        exit;
fi

#make sure everything is up to date
read -p "Do you want to upgrade existing packages? " yn
case $yn in
    [Yy]* ) $upgrade;;
    [Nn]* ) echo "Not upgrading";;
    * ) echo "Please answer yes or no.";;
esac

#If git is not installed, try to install it
echo "Checking for git..."
(which git && echo "Found git") || ($installer git-all || $installer git || echo "Could not install git")

#Try to get Vundle
echo "Trying to install Vundle..."
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim 2>&1 || echo "Could not install Vundle"
#git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim 2>&1 || { echo >&2 "Git not installed, attempting to install..."; sudo apt-get -y install git-core; git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim }

#install zsh
read -r -p "Do you want to install zsh? " yn
case $yn in
    [Yy]* ) $installer zsh;;
    [Nn]* ) echo "NOT installing zsh";;
    * ) echo "Please answer yes or no.";;
esac

#set shell to zsh
read -r -p "Do you want to set zsh as your shell? " yn
case $yn in
    [Yy]* ) chsh "$(whoami)" -s /bin/zsh;;
    [Nn]* ) echo "NOT changing shell";;
    * ) echo "Please answer yes or no.";;
esac

#make sure vim is installed
echo "Checking vim is installed..."
(which vim && echo "Found vim") || $installer vim &> /dev/null || echo "Couldn't install Vim"

#Install plugins
vim +PluginInstall +qall || echo "Couldn't install vim plugins"

# install lsof
echo "Trying to install lsof..."
$installer lsof || echo "Couldn't install lsof"

# install htop
echo "Trying to install htop..."
$installer htop || echo "Couldn't install htop"

#install ncdu
echo "Trying to install ncdu..."
$installer ncdu || echo "Couldn't install ncdu"

#install xclip
# echo "Trying to install xclip..."
# $installer xclip || echo "Couldn't install xclip"

#install tree
echo "Trying to install tree..."
$installer tree || echo "Couldn't install tree"

echo "Trying to install tldr..."
$installer tldr || echo "Couldn't install tldr"

# Pull down zsh-syntax-highlighting
git submodule init
git submodule update

# Copy zsh-syntax-highlighting to home
mkdir ~/.zsh
cp -R "$dir"/zsh-syntax-highlighting ~/.zsh && echo 'Copied zsh-syntax-highlighting to .zsh'

usedSpaceEnd=$( ( (df --total 2> /dev/null | grep total) || (df 2> /dev/null | grep disk1) ) | awk 'END{print $3;}')
installSpace=$((usedSpaceEnd-usedSpaceStart))
kilo=$((installSpace%1024))
mega=$((installSpace/1024))
giga=$((mega/1024))
echo "Installation used $giga GB, $mega MB, $kilo KB"
echo "Finished setup!"
