#!/bin/bash

#A setup file for making the environment the way I like it. I kinda-sorta made it cross-platform-ish.
#I hope for it to work on all flavors of Debian, Fedora, and OSX/Darwin. Maybe I will add arch and Cygwin later. I think openSUSE is RPM based so maybe those are covered too
#Terminal emulator is an issue as well, this should hopefully support Gnome shell, Konsole, Xfce terminal, xterm, and iTerm2. Maybe I'll add Cygwin one day
#Will probably never add Gentoo or Slackware
#Everything needs to be updated with BSD alternatives to be usable on mac

#Make sure the current folder gives us the right permissions
sudo chmod 744 $(dirname $0)/*

#Record this script's directory
#Apparently the thing dirname spits out is sometimes relative, so be careful
dir=$(dirname $0)

# make the hard links so we don't have to move them back and forth to commit/push/pull
ln -i $(dirname $0)/.vimrc ~/ &> /dev/null
ln -i $(dirname $0)/.bashrc ~/ &> /dev/null

#use the new .bashrc
source ~/.bashrc

#copy git stuff
cp $(dirname $0)/git-prompt.sh ~ &> /dev/null
cp $(dirname $0)/git-completion.bash ~ &> /dev/null

#Kill CapsLock
#currently doesn't work on mac (or at all?)
( (dumpkeys | grep keymaps; echo "keycode 58 = Escape") | loadkeys) &> /dev/null
#Maybe kill mouse accel too?

#make sure bashrc loads in login shells too
grep "source ~/.bashrc" ~/.bash_profile &> /dev/null || echo "source ~/.bashrc" >> ~/.bash_profile


#Go through all of the color schemes for popular terminal emulators and try to copy the correct files to the correct places
#Those that don't match the current terminal emulator should simply fail. I may pipe the errors to dev/null later
#iTerm2 needs to be set manually, the file to import is in the git repo

#xfce-terminal
cp terminalrc ~/.config/Terminal/terminalrc &> /dev/null || echo "Not Xfce"

#gnome
rake set scheme=solarized_dark &> /dev/null || echo "Not Gnome"

#xterm
(which xterm && cp .Xresources && xrdb -merge ~/.Xresources~) &> /dev/null || echo "Not xterm"

#Konsole
cp SolarizedDark.colorscheme ~/.kde/share/apps/konsole &> /dev/null || echo "Not Konsole"

###################################################################################################

#Don't do any fancy network stuff if simple is active
if [ "$1" = "-s" ];
then
	exit 0
fi

#note how much space we have now so we know how much we used when we're through
#hopefully this helps figure out if I can use this on, say, a Raspberry Pi
#NEEDS MAC ALT
usedSpaceStart=$(((df --total 2> /dev/null | grep total) || (df 2> /dev/null | grep disk1)) | awk 'END{print $3;}')

#major package managers: aptitude - debian, yum - fedora, homebrew - OSX, 
installer="ERROR" #somehow didnt have aptitude or yum and we're not on OSX, or something failed
#If we find yum, we also try to set two additional repos, because RHEL's defaults are kinda sucky. Not a big deal if this fails. Hopefully Fedora won't need this
#Or not, apparently you can't use alternative repos in RHEL, at least at LinkedIn... Oh well
which yum &> /dev/null && installer="sudo yum -y " && sudo rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm &> /dev/null; sudo rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm &> /dev/null
#Debian
which aptitude &> /dev/null && installer="sudo aptitude -y "
#OSX
uname &> /dev/null | grep -i darwin && ruby $(dirname $0)/homebrew_install.rb; installer="brew " && brew update && zsh $dir/di-xquartz.sh

#make sure everything is up to date, unfortunately have to use upgrade cuz homebrew
$installer upgrade

#Try to get Vundle
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim 2>&1 
#git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim 2>&1 || { echo >&2 "Git not installed, attempting to install..."; sudo apt-get -y install git-core; git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim }

#make sure vim is installed
$installer install vim &> /dev/null || echo "Couldn't install Vim"

#Install plugins
vim +PluginInstall +qall || echo "Couldn't install vim plugins"

#Install bro because I'm a noob
$installer install rubygems || echo "Couldn't install rubygems"
sudo gem install bropages || echo "Couldn't install bro"
sudo gem install rake || echo "Couldn't install rake"

#install most, should color man pages and stuff
$installer install most || echo "Could not install most"

#make sure wget is installed
#$installer install wget

#get git completion scripts
#wget -O --no-check-certificate ~/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh || echo "Couldn't fetch git-prompt.sh"
#wget -O --no-check-certificate ~/.git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash || echo "Couldn't fetch git-completion.bash"

#install autojump
$installer install autojump || echo "Couldn't install autojump"

#install lsof
$installer install lsof || echo "Couldn't install lsof"

#install htop
$installer install htop || echo "Couldn't install htop"

#install ncdu
$installer install ncdu || echo "Couldn't install ncdu"

#install xclip
$installer install xclip || echo "Couldn't install xclip"

#install tree
$installer install tree || echo "Couldn't install tree"

usedSpaceEnd=$(((df --total 2> /dev/null | grep total) || (df 2> /dev/null | grep disk1)) | awk 'END{print $3;}')
installSpace=$((usedSpaceEnd-usedSpaceStart))
kilo=$((installSpace%1024))
mega=$((installSpace/1024))
giga=$((mega/1024))
echo "Installation used $giga GB, $mega MB, $kilo KB"
