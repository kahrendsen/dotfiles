#!/bin/bash

#A setup file for making the environment the way I like it. I kinda-sorta made it cross-platform-ish.
#I hope for it to work on all flavors of Debian, Fedora, and OSX/Darwin. Maybe I will add arch and Cygwin later. I think openSUSE is RPM based so maybe those are covered too
#Terminal emulator is an issue as well, this should hopefully support Gnome shell, Konsole, Xfce terminal, xterm, and iTerm2. Maybe I'll add Cygwin one day
#Will probably never add Gentoo or Slackware


# make the hard links so we don't have to move them back and forth to commit/push/pull
ln .vimrc ~/
ln .bashrc ~/

#use the new .bashrc
source ~/.bashrc

#Kill CapsLock
(dumpkeys | grep keymaps; echo "keycode 58 = Escape") | loadkeys

#make sure bashrc loads in login shells too
echo "source ~/.bashrc" >>


#Don't do any fancy network stuff if simple is active
if [ "$1" = "s" ];
then
	exit 0
fi

#note how much space we have now so we know how much we used when we're through
#hopefully this helps figure out if I can use this on, say, a Raspberry Pi
usedSpaceStart=$(df --total | grep total | awk 'END{print $3;}')

#major package managers: aptitude - debian, yum - fedora, homebrew - OSX, 
installer="ERROR" #somehow didn't have aptitude or yum and we're not on OSX, or something failed
#If we find yum, we also try to set two additional repos, because RHEL's defaults are kinda sucky. Not a big deal if this fails. Hopefully Fedora won't need this
which yum && installer="sudo yum -y " && sudo rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm && sudo rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
which aptitude && installer="sudo aptitude -y "
uname | grep -i darwin && sudo ruby -e homebrew_install.rb && installer="homebrew " && brew update

#make sure everything is up to date, unfortunately have to use upgrade cuz homebrew
$installer upgrade

#Try to get Vundle
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim 2>&1 
#git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim 2>&1 || { echo >&2 "Git not installed, attempting to install..."; sudo apt-get -y install git-core; git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim }

#make sure vim is installed
$installer install vim || echo "Couldn't install Vim"

#Install plugins
vim +PluginInstall +qall || echo "Couldn't install vim plugins"

#Install bro because I'm a noob
$installer install rubygems || echo "Couldn't install rubygems"
gem install bropages || echo "Couldn't install bro"

#install most and set as default more, should color man pages and stuff
$installer install most && update-alternatives --set pager /usr/bin/most || echo "Could not install most"

#make sure wget is installed
$installer install wget

#get git completion scripts
wget -O ~/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh || echo "Couldn't fetch git-prompt.sh"
wget -O ~/.git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash || echo "Couldn't fetch git-completion.bash"

#install autojump
$installer install autojump || echo "Couldn't install autojump"

#install htop
$installer install htop || echo "Couldn't install htop"

#install ncdu
$installer install ncdu || echo "Couldn't install ncdu"

#install xclip
$installer install xclip || echo "Couldn't install xclip"

#Go through all of the color schemes for popular terminal emulators and try to copy the correct files to the correct places
#Those that don't match the current terminal emulator should simply fail. I may pipe the errors to dev/null later
#iTerm2 needs to be set manually, the file to import is in the git repo

#xfce-terminal
cp terminalrc ~/.config/Terminal/terminalrc || echo "Not Xfce"

#gnome
rake set scheme=solarized_dark || echo "Not Gnome"

#xterm
which xterm && cp .Xresources && xrdb -merge ~/.Xresources~ || echo "Not xterm"

#Konsole
cp SolarizedDark.colorscheme ~/.kde/share/apps/konsole || echo "Not Konsole"


usedSpaceEnd=$(df --total | grep total | awk 'END{print $3;}')
installSpace=$usedSpaceEnd-$usedSpaceStart
kilo=$installSpace%1024
mega=$installSpace/1024
giga=$mega/1024
echo "Installation used $giga GB, $mega MB, $kilo KB"