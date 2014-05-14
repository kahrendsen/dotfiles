
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

#256 Color
if [ -e /usr/share/terminfo/x/xterm-256color ]; then
        export TERM='xterm-256color'
else
        export TERM='xterm-color'
fi


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
shopt -s dirspell





