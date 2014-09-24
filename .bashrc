
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

#256 Color, i guess only works for xterm?
if [ -e /usr/share/terminfo/x/xterm-256color ]; then
        export TERM='xterm-256color'
else
        export TERM='xterm-color'
fi


#Define a bunch of colors

# Reset
Color_Off="\[\033[0m\]"       # Text Reset

# Regular Colors
Black="\[\033[0;30m\]"        # Black
Red="\[\033[0;31m\]"          # Red
Green="\[\033[0;32m\]"        # Green
Yellow="\[\033[0;33m\]"       # Yellow
Blue="\[\033[0;34m\]"         # Blue
Purple="\[\033[0;35m\]"       # Purple
Cyan="\[\033[0;36m\]"         # Cyan
White="\[\033[0;37m\]"        # White

# Bold
BBlack="\[\033[1;30m\]"       # Black
BRed="\[\033[1;31m\]"         # Red
BGreen="\[\033[1;32m\]"       # Green
BYellow="\[\033[1;33m\]"      # Yellow
BBlue="\[\033[1;34m\]"        # Blue
BPurple="\[\033[1;35m\]"      # Purple
BCyan="\[\033[1;36m\]"        # Cyan
BWhite="\[\033[1;37m\]"       # White

# Underline
UBlack="\[\033[4;30m\]"       # Black
URed="\[\033[4;31m\]"         # Red
UGreen="\[\033[4;32m\]"       # Green
UYellow="\[\033[4;33m\]"      # Yellow
UBlue="\[\033[4;34m\]"        # Blue
UPurple="\[\033[4;35m\]"      # Purple
UCyan="\[\033[4;36m\]"        # Cyan
UWhite="\[\033[4;37m\]"       # White

# Background
On_Black="\[\033[40m\]"       # Black
On_Red="\[\033[41m\]"         # Red
On_Green="\[\033[42m\]"       # Green
On_Yellow="\[\033[43m\]"      # Yellow
On_Blue="\[\033[44m\]"        # Blue
On_Purple="\[\033[45m\]"      # Purple
On_Cyan="\[\033[46m\]"        # Cyan
On_White="\[\033[47m\]"       # White

# High Intensty
IBlack="\[\033[0;90m\]"       # Black
IRed="\[\033[0;91m\]"         # Red
IGreen="\[\033[0;92m\]"       # Green
IYellow="\[\033[0;93m\]"      # Yellow
IBlue="\[\033[0;94m\]"        # Blue
IPurple="\[\033[0;95m\]"      # Purple
ICyan="\[\033[0;96m\]"        # Cyan
IWhite="\[\033[0;97m\]"       # White

# Bold High Intensty
BIBlack="\[\033[1;90m\]"      # Black
BIRed="\[\033[1;91m\]"        # Red
BIGreen="\[\033[1;92m\]"      # Green
BIYellow="\[\033[1;93m\]"     # Yellow
BIBlue="\[\033[1;94m\]"       # Blue
BIPurple="\[\033[1;95m\]"     # Purple
BICyan="\[\033[1;96m\]"       # Cyan
BIWhite="\[\033[1;97m\]"      # White

# High Intensty backgrounds
On_IBlack="\[\033[0;100m\]"   # Black
On_IRed="\[\033[0;101m\]"     # Red
On_IGreen="\[\033[0;102m\]"   # Green
On_IYellow="\[\033[0;103m\]"  # Yellow
On_IBlue="\[\033[0;104m\]"    # Blue
On_IPurple="\[\033[10;95m\]"  # Purple
On_ICyan="\[\033[0;106m\]"    # Cyan
On_IWhite="\[\033[0;107m\]"   # White

# Various variables for PS1 prompt 
Time12h="\T"
Time12a="\@"
PathShort="\w"
#PathFull="\W" misleading?
NewLine="\n"
Jobs="\j"


# Enable options:
#Correct spelling in cd
shopt -s cdspell
#Can cd using var as directory
shopt -s cdable_vars
#Check hashtable for command
shopt -s checkhash
#Update LINES and COLUMNS after command completion
shopt -s checkwinsize
shopt -s no_empty_cmd_completion
#Saves multi-line commands in single history entry
shopt -s cmdhist
shopt -s histappend histreedit histverify
#Extended pattern matching features
shopt -s extglob       # Necessary for programmable completion.
#Attempt to correct spelling of directory names when word completing if directory doesn't exist
shopt -s dirspell &> /dev/null


export HISTFILESIZE=500000
export HISTSIZE=100000
export PATH="$PATH:~/.cabal/bin"

#load autojump
. /usr/share/autojump/autojump.sh 2&> /dev/null

#attempt to load git completion scripts
#if [[ -f ~/.git-prompt.sh ]]; then true else wget -O ~/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > /dev/null; fi
#if [[ -f ~/.git-completion.bash ]]; then true else wget -O ~/.git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > /dev/null; fi
source ~/git-completion.bash &> /dev/null
source ~/git-prompt.sh &> /dev/null

#This is executed every time we're about to show a prompt, so the sanest way to build PS1 is to use this
#Otherwise we get totally unreadable strings from hell
PROMPT_COMMAND="set_prompt"


function set_prompt {

    #We're gonna try to make this shit readable if it kills us.

    local last_command=$? # Must come first!
    local rootCol=$(if [[ $(id -u) -eq "0" ]]; then echo "$BRed"; else echo "$BCyan"; fi)

    PS1=""

    #Time stamp
    PS1+="$Blue$Time12h$Color_Off "
    #Status of last command
    local happy=":D"
    local sad="D:"
    PS1+=$(if [[ $last_command -eq 0 ]]; then echo "$Green$happy$Color_Off "; else echo "$Red$sad$Color_Off "; fi)
    #name@machine if ssh'd
    local ssh_var="ssh:\u@\h "
    PS1+=$(if [[ -n "$SSH_CLIENT" ]]; then echo "$rootCol$ssh_far$Color_Off "; else echo ""; fi)
    #Working directory
    PS1+="$rootCol$PathShort$Color_Off "
    #Git branch
    PS1+=$(git_branch_ps1)
    #newline
    PS1+="$NewLine"
    #Finally, $ or #
    PS1+='\$'

}

function git_branch_ps1 {
    #This'll just echo the appropriate string for inserting the current git branch in the correct color
    
    #Shows a % if there are untracked files, helps with forgetting to add things
    GIT_PS1_SHOWUNTRACKEDFILES=1

    #are we in a branch at all?
    git branch &>/dev/null;
    if [ $? -eq 0 ]; then
        #we're in a branch. Do we have uncommited changes?
        git status 2> /dev/null | grep "nothing to commit" > /dev/null 2>&1;
        if [ "$?" -eq "0" ]; then
            #Nothing to commit
            echo "$Green$(__git_ps1 "(%s)")$Color_Off";
        else
            #uncommitted changes
            echo "$Red$(__git_ps1 "{%s}")$Color_Off";
        fi;
    fi;

}


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
alias more='most'
alias less='most'
# Pretty-print of some PATH variables:
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
alias l='ls'
alias s='ls'
alias sl='ls'

#I think most of these are pretty broken
#function soffice() { command soffice "$@" & }
function firefox() { firefox "$@" & &> /dev/null || /usr/bin/firefox "$@" & &> /dev/null || open firefox "$@" &> /dev/null; }
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
    firefox https://github.com/settings/ssh
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
        sudo chown -R $ /usr/local/bin;
    fi
    cp -ri $user /usr/local/bin;


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


#Stuff to print out at the beginning of the session
echo "$(date +"%A %B %d %Y @ %r")"
printf "$(id -un)@$(hostname)\n\n"
which cowsay &> /dev/null && cowsay -f meow "Meow.";


#umask 022

#Maybe just shoulda used this... https://github.com/nojhan/liquidprompt
