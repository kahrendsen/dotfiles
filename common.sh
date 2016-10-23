
function dvim(){
    if [ -n "$1" ]
    then
        line=0;
        ty=$(type -t $1)
        case "$ty" in
            alias) line=$(grep -Ens -m1 "alias[[:space:]]*(-g)?[[:space:]]*[[:alnum:]]*$1[[:alnum:]]*[[:space:]]*=" ~/.bashrc ~/common.sh ~/.zshrc) ;;
        function) line=$(grep -Ens -m1 "(function)?[[:space:]]*[[:alnum:]]*$1[[:alnum:]]*[[:space:]]*\(?.*\)?" ~/.bashrc ~/common.sh ~/.zshrc) ;; # TODO this needs to be "function foo OR foo ()" as the search criteria
        esac

        line_num=$(echo "$line" | cut -d: -f2)
        filename=$(echo "$line" | cut -d: -f1)
        vim $filename +$line_num

    else
        vim ~/common.sh
    fi



}


#function http() {
    #curl http://httpcode.info/"$1"
#}

function up {
    if [ $# -eq 0 ]; then
    	cd ..;
    else
    	count=0
        cdStr="";
    	while [[ count -lt $1 ]]
    	do
    		cdStr+="../"
			(( count+=1 ))
    	done;
        cd $cdStr
    fi;
}



#alias rm=gvfs-trash
#alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test100.zip'
alias grep='grep --color=auto' #MAC OK?
alias ll='ls -Alv' #MAC OK
ls -h --color=auto &> /dev/null && alias ls='ls -h --color=auto' || alias ls='ls -hG' #Always colorize and use sensible sizes, should now be MAC OK
alias vi='vim'
alias la='ls -A'           #  Show hidden files, MAC OK
#ls -lXB &> /dev/null && alias lx='ls -lXB'         #  Sort by extension. XB NOT OK, X - File Extension, B - don't list backups
#alias lk='ls -lSr'         #  Sort by size, biggest last. MAC OK
#alias lt='ls -lt'         #  Sort by date, most recent first. MAC OK
#alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.MAC OK
#alias lu='ls -ltur'        #  Sort by/show access time,most recent last.MAC OK
#alias lm='ll |less'        #  Pipe through 'less'MAC OK 
#alias lr='ll -R'           #  Recursive ls. MAC OK
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
#Quick access to the config files
alias vimrc='vim ~/.vimrc'
alias bashrc='vim ~/.bashrc'
alias zshrc='vim ~/.zshrc'


#Use 'command not found' if possible
 [ -r /etc/profile.d/cnf.sh ] && . /etc/profile.d/cnf.sh 

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

# we () #I'm copying this from some guys dotfiles, it could be broken for all I know
# {
# local __doc__='Edit the first argument if it is a function or alias'

# if [[ "$(type -t $1)" == "function" ]]
# then
# _de_declare_function $1
# _edit_function
# elif [[ "$(type -t $1)" == "alias" ]]
# then
# _edit_alias $1
# else type $1
# fi
# }

# _de_declare_function ()
# {
# local __doc__='Set symbols for the file and line of a function'
# _parse_declaration $(_debug_declare_function $1)
# }

# _parse_declaration ()
# {
# local __doc__='extract the ordered arguments from a debug declare'
# function=$1;
# shift;
# line_number=$1;
# shift;
# path_to_file="$*";
# }

# _debug_declare_function ()
# {
# local __doc__='Find where the first argument was loaded from';
# bash -c 'shopt -s extdebug;declare -F $1; shopt -u extdebug;';



# }


# _edit_function ()
# {
# local __doc__='Edit a function in a file'
# _make_path_to_file_exist
# if [[ -n "$line_number" ]]
# then
# $EDITOR $path_to_file +$line_number
# else
# local regexp="^$function[[:space:]]*()[[:space:]]*$"
# if ! grep -q $regexp $path_to_file
# then declare -f $function >> $path_to_file
# fi
# $EDITOR $path_to_file +/$regexp
# fi
# ls -l $path_to_file
# source $path_to_file
# [[ $(dirname $path_to_file) == /tmp ]] && rm -f $path_to_file
# }

# _make_path_to_file_exist ()
# {
# local __doc__='make sure the required file exists, either an existing file, a new file, or a temp file'
# if [[ -n $path_to_file ]]
# then
# if [[ -f $path_to_file ]]
# then
# cp $path_to_file $path_to_file~
# else
# _write_new_file $path_to_file
# if [[ $function == $unamed_function ]]
# then
# line_number=$(wc -l $path_to_file)
# declare -f $unamed_function >> $path_to_file
# fi
# fi
# else
# path_to_file=$(mktemp /tmp/function.XXXXXX)
# fi
# }

# _write_new_file ()
# {
# local __doc__='Copy the head of this script to file'
# echo "#! /bin/sh\n" > $path_to_file
# }





#Stuff to print out at the beginning of the session
echo "$(date +"%A %B %d %Y @ %r")"
printf "$(id -un)@$(hostname)\n\n"
which cowsay &> /dev/null && cowsay -f meow "Meow.";


#umask 022

