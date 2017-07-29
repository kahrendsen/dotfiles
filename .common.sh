
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
alias grep='grep --color=auto' #MAC OK?
alias ll='ls -Alv' #MAC OK
ls -h --color=auto &> /dev/null && alias ls='ls -h --color=auto' || alias ls='ls -hG' #Always colorize and use sensible sizes, should now be MAC OK
alias vi='vim'
alias la='ls -A'           #  Show hidden files, MAC OK
alias mkdir='mkdir -p' #Make intermediate directories as required, MAC OK
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
# Open files from terminal
which xdg-open && alias open=xdg-open


#Use 'command not found' if possible
 [ -r /etc/profile.d/cnf.sh ] && . /etc/profile.d/cnf.sh 

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

#Automate the slightly irritating process to get RSA keys onto GitHub.
function ezkey() 
{
    pushd "$(pwd)"
    cd ~/.ssh || return 1
    ssh-keygen
    ssh-add id_rsa
    which xclip &> /dev/null && xclip -sel clip < ~/.ssh/id_rsa.pub
    cat ~/.ssh/id_rsa.pub
    open https://github.com/settings/ssh 
    popd | cd || return 1
}

google() {
    search="$1"
    for term in "${@:2}"; # This is an array slice from index 2 to the end
    do
        search="$search%20$term"
    done
    echo $search
    open "http://www.google.com/search?q=$search"
}

so() {
    search="$1"
    for term in "${@:2}"; 
    do
        search="$search%20$term"
    done
    echo $search
    open "https://stackoverflow.com/search?q=$search"
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

#function savepath()
#{
   #echo "export PATH=$PATH" >> ~/.bash_profile
#}

#Stuff to print out at the beginning of the session
echo "$(date +"%A %B %d %Y @ %r")"
printf "$(id -un)@$(hostname)\n\n"
which cowsay &> /dev/null && cowsay -f meow "Meow.";

