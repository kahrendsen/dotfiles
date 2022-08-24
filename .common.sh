#!/usr/bin/env ksh
# shellcheck disable=SC2111
# ksh gets us close enough to the intersection between bash and zsh
# should probably run the zsh side with emulate -L ksh

##### Aliases
#alias rm=gvfs-trash
alias grep='grep --color="auto"' #MAC OK?
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
alias bashrclocal='vim ~/.bashrc.local'
alias zshrc='vim ~/.zshrc'
alias zshrclocal='vim ~/.zshrc.local'
alias commonsh='vim ~/.common.sh'
# Open files or urls from terminal
which xdg-open &> /dev/null && alias open=xdg-open
which xdg-open &> /dev/null && alias github='echo "Use:\nssh-keygen -t ed25519\nOR\nssh-keygen -t rsa\nThen ssh-add\nThen:\ncat ~/.ssh/id_ed25519.pub\nOR\ncat~/.ssh/id_rsa.pub\nOr, use ezkey" && xdg-open "https://github.com/settings/ssh/new"'
# Android
alias fgActivity="adb shell dumpsys window windows | grep -E 'mCurrentFocus|mFocusedApp'"
alias androidVersion='adb shell getprop ro.build.display.id'
alias adbb='adb shell am broadcast -a'
alias screenshot='adb shell screencap -p /sdcard/screenshot.png && adb pull /sdcard/screenshot.png'
alias recordscreen='adb shell screenrecord /sdcard/video.mp4'
alias pullvideo='adb pull /sdcard/video.mp4'
alias logcat='adb logcat'
alias sendtext='adb shell input text'
alias noprune='adb logcat -P ""'
alias killCanary='adb shell setprop log.tag.LeakCanaryMagicFlag ERROR'



##### Functions
up() {
    if [[ $# -eq 0 ]]; then
        cd ..;
    else
        count=0
        cdStr="";
        while [[ count -lt "$1" ]]
        do
            cdStr+="../"
            (( count+=1 ))
        done;
        cd $cdStr || return 1
    fi;
}

swap()
{ # Swap 2 filenames around, if they exist (from Uzi's bashrc).
    local TMPFILE=tmp.$$

    [ $# -ne 2 ] && echo "swap: 2 arguments needed" && return 1
    [ ! -e "$1" ] && echo "swap: $1 does not exist" && return 1
    [ ! -e "$2" ] && echo "swap: $2 does not exist" && return 1

    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}

#Automate the slightly irritating process to get RSA keys onto GitHub.
ezkey()
{
    pushd "$(pwd)" || (echo "pushd failed" && exit)
    cd ~/.ssh || return 1
    ssh-keygen
    ssh-add id_rsa
    which xclip &> /dev/null && xclip -sel clip < ~/.ssh/id_rsa.pub
    cat ~/.ssh/id_rsa.pub
    open https://github.com/settings/ssh 
    popd | xargs cd || return 1
}

google() {
    search="$1"
    for term in "${@:2}"; # This is an array slice from index 2 to the end
    do
        search="$search%20$term"
    done
    echo "$search"
    open "http://www.google.com/search?q=$search"
}

so() {
    search="$1"
    for term in "${@:2}"; 
    do
        search="$search%20$term"
    done
    echo "$search"
    open "https://stackoverflow.com/search?q=$search"
}

addpath()
{
    if [ $# -eq 0 ]
    then
        export PATH=$PATH:$(pwd)
    else
        export PATH=$PATH:$1
    fi

}

function getAndroidId() {
  adb root
  adb shell 'sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select value from main where name = \"android_id\";"'
}

#function savepath()
#{
   #echo "export PATH=$PATH" >> ~/.bash_profile
#}

# For quickly editing a given function/alias in the dotfiles
# Currently broken
#dotedit(){
    #if [ -n "$1" ]
    #then
        #line=0;
        #ty=$(type -t "$1")
        #case "$ty" in
            #alias) line=$(grep -Ens -m1 "alias[[:space:]]*(-g)?[[:space:]]*[[:alnum:]]*$1[[:alnum:]]*[[:space:]]*=" ~/.bashrc ~/common.sh ~/.zshrc) ;;
        #function) line=$(grep -Ens -m1 "(function)?[[:space:]]*[[:alnum:]]*$1[[:alnum:]]*[[:space:]]*\(?.*\)?" ~/.bashrc ~/common.sh ~/.zshrc) ;; # TODO this needs to be "function foo OR foo ()" as the search criteria
        #esac

        #line_num=$(echo "$line" | cut -d: -f2)
        #filename=$(echo "$line" | cut -d: -f1)
        #vim "$filename" +"$line_num"

    #else
        #vim ~/common.sh
    #fi
#}

##### Prompt

function set_prompt {
    PS1="$(get_prompt_str)"
}

function get_prompt_str {
    local last_command=$? # Must come first!
    local rootCol
    rootCol=$(if [[ $(id -u) -eq "0" ]]; then echo "$L_RED"; else echo "$L_CYAN"; fi)

    if [ -z "$NO_STATUS_LINE" ]; then
        #Date
        local date_str="$BLUE$DATE$COLOR_OFF"
        #Time stamp
        local time_str="$BLUE$TIME24H$COLOR_OFF"
        #Status of last command
        local happy=":D"
        local sad="D:"
        local last_cmd
        last_cmd=$(if [[ $last_command -eq 0 ]]; then echo "$GREEN$happy$COLOR_OFF"; else echo "$RED$sad$COLOR_OFF"; fi)
        #name@machine if ssh'd
        local ssh_var="ssh:$USERNAME_PROMPT@$HOSTNAME_PROMPT "
        local ssh_out
        ssh_out=$(if [[ -n "$SSH_CLIENT" ]]; then echo "$rootCol$ssh_var$COLOR_OFF "; else echo ""; fi)
        #Working directory
        local working_dir="$rootCol$PATH_SHORT$COLOR_OFF"
        #Git branch
        local git_info
        git_info=$(git_branch_ps1)
    fi
    # Virutal env
    local virtual_env_str
    virtual_env_str=$(add_venv_info)
    #Finally, $ or #
    local prompt_char="$rootCol\$$COLOR_OFF"
    printf "%s|%s %s %s%s %s%s%s%s" "$date_str" "$time_str" "$last_cmd" "$ssh_out" "$working_dir" "$git_info" "$NEWLINE" "$virtual_env_str" "$prompt_char"
}

# Load git prompt script
source ~/git-prompt.sh &> /dev/null

function git_branch_ps1 {
    #This'll just echo the appropriate string for inserting the current git branch in the correct color
    
    #Shows a % if there are untracked files, helps with forgetting to add things
    # GIT_PS1_SHOWUNTRACKEDFILES=1

    #Do we have uncommited changes?
    if ! git diff --no-ext-diff --quiet --exit-code 2> /dev/null || ! git diff-index --cached --quiet HEAD 2> /dev/null
    then
        #uncommitted changes
        echo "$RED$(__git_ps1 "{%s}" 2> /dev/null)$COLOR_OFF";
    else
        #Nothing to commit
        echo "$GREEN$(__git_ps1 "(%s)" 2> /dev/null)$COLOR_OFF";
    fi
}
# Virtual ENV stuff
# https://stackoverflow.com/questions/14987013
add_venv_info () {
    if [ -z "$VIRTUAL_ENV_DISABLE_PROMPT" ] ; then
        VIRT_ENV_TXT=""
        if [ "x" != x ] ; then
            # This is supposedly a way to determine if we're using a bash-like shell (but I'm not sure how)
            VIRT_ENV_TXT=""
        elif [ "$VIRTUAL_ENV" != "" ]; then
            VIRT_ENV_TXT="(`basename \"$VIRTUAL_ENV\"`)"
        fi
        if [ "${VIRT_ENV_TXT}" != "" ]; then
           echo ${VIRT_ENV_TXT}" "
        fi
    fi
}
##### Load scripts
#Use 'command not found' if possible
 [ -r /etc/profile.d/cnf.sh ] && . /etc/profile.d/cnf.sh 

# Add local installed files to path
export PATH=$PATH:~/.local/bin:~/bin


#Stuff to print out at the beginning of the session
date +"%A %B %d %Y @ %r"
printf "$(id -un)@$(hostname)\n\n"
which cowsay &> /dev/null && cowsay -f meow "Meow.";

