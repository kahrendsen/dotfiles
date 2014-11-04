
function http() {
    curl http://httpcode.info/"$1"
}

function up {
    if [ $# -eq 0 ]; then
    	cd ..;
    else
    	count=0
    	while [[ count -lt $1 ]]
    	do
    		cd ..
			(( count+=1 ))
    	done;
    fi;
}



#alias rm=gvfs-trash
alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test100.zip'
alias grep='grep --color=auto' #MAC OK?
alias ll='ls -Alv' #MAC OK
ls -h --color=auto &> /dev/null && alias ls='ls -h --color=auto' || alias ls='ls -hG' #Always colorize and use sensible sizes, should now be MAC OK
alias la='ls -A'           #  Show hidden files, MAC OK
ls -lXB &> /dev/null && alias lx='ls -lXB'         #  Sort by extension. XB NOT OK, X - File Extension, B - don't list backups
alias lk='ls -lSr'         #  Sort by size, biggest last. MAC OK
alias lt='ls -lt'         #  Sort by date, most recent first. MAC OK
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.MAC OK
alias lu='ls -ltur'        #  Sort by/show access time,most recent last.MAC OK
alias lm='ll |less'        #  Pipe through 'less'MAC OK 
alias lr='ll -R'           #  Recursive ls. MAC OK
which tree &> /dev/null && alias tree='tree -Csh'    #  Nice alternative to 'recursive ls' ... (MAC OK if tree is installed)
alias mkdir='mkdir -p' #Make intermediate directories as required, MAC OK
#alias more='most'
#alias less='most'
# Pretty-print of some PATH variables:
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
alias l='ls'
alias s='ls'
alias sl='ls'

#I think most of these are pretty broken
#function soffice() { command soffice "$@" & }
#function firefox() { firefox "$@" & &> /dev/null || /usr/bin/firefox "$@" & &> /dev/null || open firefox "$@" &> /dev/null; }
#function xpdf() { command xpdf "$@" & }


function swap()
{ # Swap 2 filenames around, if they exist (from Uzi's bashrc).
    local TMPFILE=tmp.$$

    [ $# -ne 2 ] && echo "swap: 2 arguments needed" && return 1
    [ ! -e $1 ] && echo "swap: $1 does not exist" && return 1
    [ ! -e $2 ] && echo "swap: $2 does not exist" && return 1

    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}

function extract()      # Handy Extract Program
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.rar)       unrar x $1      ;;
            *.gz)        gunzip $1       ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress $1   ;;
            *.7z)        7z x $1         ;;
            *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!";
    fi
}


# Creates an archive (*.tar.gz) from given directory.
function maketar() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }

# Create a ZIP archive of a file or folder.
function makezip() { zip -r "${1%%/}.zip" "$1" ; }

# Make your directories and files access rights sane.
function sanitize() { chmod -R u=rwX,g=rX,o= "$@" ;}


function killps()   # kill by process name
{
    local pid pname sig="-TERM"   # default signal
    if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
        echo "Usage: killps [-SIGNAL] pattern"
        return;
    fi
    if [ $# = 2 ]; then sig=$1 ; fi
    for pid in $(my_ps| awk '!/awk/ && $0~pat { print $1 }' pat=${!#} )
    do
        pname=$(my_ps | awk '$1~var { print $5 }' var=$pid )
        if ask "Kill process $pid <$pname> with signal $sig?"
            then kill $sig $pid
        fi
    done
}


function getIP() # Get IP adress on ethernet.
{
    MY_IP=$(/sbin/ifconfig eth0 | awk '/inet/ { print $2 } ' |
      sed -e s/addr://)
    echo ${MY_IP:-"Not connected"}
}


function repeat()       # Repeat n times command.
{
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do  # --> C-like syntax
        eval "$@";
    done
}

#Automate the slightly irritating process to get RSA keys onto GitHub.
#Note if I get this the way I'm hoping, it'll probably be pretty unsafe since I'm lazy about passphrases
function ezkey() 
{
    pushd "$(pwd)"
    cd ~/.ssh
    ssh-keygen -A
    ssh-add id_rsa
    which xclip &> /dev/null && xclip -sel clip < ~/.ssh/id_rsa.pub
    ~/.ssh/id_rsa.pub | echo
    firefox https://github.com/settings/ssh #should use that default-thing here
	popd | cd
}

#Hopefully will automatically execute the last line of the stderr to be printed
#Useful for "X, not installed, type sudo apt-get to install"
function doit()
{
    eval "$(!! 2>&1 >/dev/null | tail -1 )"
}

function killport()
{
    #pid=$(lsof -i:$1 -t); 
    #kill $pid || kill -s 9 $pid;
    #lsof -i tcp:${PORT_NUMBER} | awk 'NR!=1 {print $2}' | xargs kill
    PID=$(lsof -i:$1 | grep 'username' | awk '{print $2}')
    if [ $PID ]; then
        kill $PID;
    fi
}

function installbin()
{
    user=`id -un`;
    if [ ! -w /usr/local/bin ];
    then
        sudo chown -R $user /usr/local/bin;
    fi
    #cp -ri $user /usr/local/bin;
    install $1 /usr/local/bin;


}

function addpath()
{
    if [ $# -eq 0 ]
    then
        export PATH=$PATH:$(pwd)
    else
        export PATH=$PATH:$1
    fi

}

function savepath()
{
   echo "export PATH=$PATH" >> ~/.bash_profile
}


#Stuff to print out at the beginning of the session
echo "$(date +"%A %B %d %Y @ %r")"
printf "$(id -un)@$(hostname)\n\n"
which cowsay &> /dev/null && cowsay -f meow "Meow.";


#umask 022

