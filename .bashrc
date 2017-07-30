# If not running interactively, don't do anything
[ -z "$PS1" ] && return
#[[ -z "$TMUX" ]] && exec tmux

# TMUX
#if which tmux >/dev/null 2>&1; then
#    #if not inside a tmux session, and if no session is started, start a #new session
#    test -z "$TMUX" && (tmux attach || tmux new-session)
#fi


#256 Color, i guess only works for xterm?
if [ -e /usr/share/terminfo/x/xterm-256color ]; then
        export TERM='xterm-256color'
#else
        #export TERM='xterm-color'
fi


# Define ANSI colors
# These are interpreted by the terminal. Bash requires non-printing escape sequences to be enclosed in "\[\033[" and "\]"

# Reset
COLOR_OFF="\[\033[0m\]"       # Text Reset

# Regular Colors
BLACK="\[\033[0;30m\]"        # Black
RED="\[\033[0;31m\]"          # Red
GREEN="\[\033[0;32m\]"        # Green
YELLOW="\[\033[0;33m\]"       # Yellow
BLUE="\[\033[0;34m\]"         # Blue
PURPLE="\[\033[0;35m\]"       # Purple
CYAN="\[\033[0;36m\]"         # Cyan
WHITE="\[\033[0;37m\]"        # White

# Light (or bold, usually printed as light)
L_Black="\[\033[1;30m\]"       # Black
L_RED="\[\033[1;31m\]"         # Red
L_GREEN="\[\033[1;32m\]"       # Green
L_YELLOW="\[\033[1;33m\]"      # Yellow
L_BLUE="\[\033[1;34m\]"        # Blue
L_PURPLE="\[\033[1;35m\]"      # Purple
L_CYAN="\[\033[1;36m\]"        # Cyan
L_WHITE="\[\033[1;37m\]"       # White

# Underline
U_BLACK="\[\033[4;30m\]"       # Black
U_RED="\[\033[4;31m\]"         # Red
U_GREEN="\[\033[4;32m\]"       # Green
U_YELLOW="\[\033[4;33m\]"      # Yellow
U_BLUE="\[\033[4;34m\]"        # Blue
U_PURPLE="\[\033[4;35m\]"      # Purple
U_CYAN="\[\033[4;36m\]"        # Cyan
U_WHITE="\[\033[4;37m\]"       # White

# Background
ON_BLACK="\[\033[40m\]"       # Black
ON_RED="\[\033[41m\]"         # Red
ON_GREEN="\[\033[42m\]"       # Green
ON_YELLOW="\[\033[43m\]"      # Yellow
ON_BLUE="\[\033[44m\]"        # Blue
ON_PURPLE="\[\033[45m\]"      # Purple
ON_CYAN="\[\033[46m\]"        # Cyan
ON_WHITE="\[\033[47m\]"       # White

# Variables for PS1 prompt 
TIME12H="\T"
TIME24H="\t"
TIME12A="\@" # AM/PM
DATE="\D{%m/%d}"
PATH_SHORT="\w"
NEWLINE="\n"
USERNAME_PROMPT="\u"
HOSTNAME_PROMPT="\h"

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

#attempt to load git completion scripts
source ~/git-completion.bash &> /dev/null

PROMPT_COMMAND="set_prompt"


source ~/.common.sh
if [ -e ~/.bashrc.local ];
then
    source ~/.bashrc.local;
fi
