#!/usr/bin/env zsh

#[[ -z "$TMUX" ]] && exec tmux
 
# TMUX
#if which tmux >/dev/null 2>&1; then
    ##if not inside a tmux session, and if no session is started, start a new session
    #test -z "$TMUX" && (tmux attach || tmux new-session)
#fi


##### Settings
# Zsh options are case insensitive and ignore _

bindkey -e # Emacs mode for line editing

# zstyle is basically a way to configure specific subsystems, as opposed to global configuration you get from setopt or exported vars
# See: 
#     https://unix.stackexchange.com/questions/214657
#     http://zsh.sourceforge.net/Doc/Release/Zsh-Modules.html#The-zsh_002fzutil-Module
#     http://bewatermyfriend.org/p/2012/003/
# Commands are of the form: zstyle "context-pattern" style value(s)

# The completion system, compsys, defines all of its styles under the :completion prefix
# Contexts for compsys are of the form: :completion:<func>:<completer>:<command>:<argument>:<tag>
# See http://zsh.sourceforge.net/Guide/zshguide06.html#l154 for an explanation of the context strings for compsys
# For all available styles available to compsys, see http://zsh.sourceforge.net/Doc/Release/Completion-System.html#Standard-Styles
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate # Defines which completers to use and their order, see http://zsh.sourceforge.net/Doc/Release/Completion-System.html#Control-Functions
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'm:{a-zA-Z}={A-Za-z} l:|=* r:|=*' #Should match in this priority: exact, case insensitive from beginning of word, case insensitive anywhere. See http://zsh.sourceforge.net/Doc/Release/Completion-Widgets.html#Completion-Matching-Control
zstyle ':completion:*' menu select # Always do "menu-style" auto completion, with navigatable grid of selection options
zstyle ':completion:*' list-colors '' # Use default colors, which should be the ls colors
zstyle :compinstall filename '/home/kendall/.zshrc' # Added by compintall, not sure

setopt appendhistory # Append history entries to end of history file
setopt hist_ignore_dups # Ignore duplicate in history.
setopt hist_ignore_space # Prevent record in history entry if preceding them with at least one space
setopt inc_append_history_time

setopt interactivecomments # Ignore lines prefixed with '#'.
setopt extendedglob # Better filename expansion (~ -> /home/kahrends)
unsetopt beep # No annoying beep
setopt noflowcontrol # Disable flow control, not entirely sure what this does
setopt noclobber # Don’t write over existing files with >, use >! instead
setopt sharehistory # Load and write history right away (use set-local-history for commands that need to navigate locally)

autoload -Uz compinit
compinit # Enable completions
zmodload zsh/complist # Not entirely sure why, but this needs to be loaded before we're allowed to set up keys for the menuselect key table

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs # Enable cdr for recent directory navigation, see http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Recent-Directories
zstyle ':chpwd:*' recent-dirs-max 40 # chpwd is config for cdr
#zstyle ':chpwd:*' recent-dirs-file ~/.chpwd-recent-dirs-${TTY##*/} + # Way to do per-terminal recent dirs
zstyle ':chpwd:*' recent-dirs-default true # Fall through to cd
zstyle ':chpwd:*' recent-dirs-insert true # Insert the actual dir name instead of the number (doesn't seem to work?)


##### Keybindings

# Control-x-e to open current line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line # zsh needs functions to become "widgets" to bind them to keys, zle -N defines a "user-defined" widget
bindkey '^x^e' edit-command-line

bindkey "^[q" push-line-or-edit # ^[ is escape. If on first editor line, pops the current contents until after a different cmd is run, else turns multi-line quote to editable form (can navigate with arrows/backspace through)
bindkey -M menuselect '^ ' accept-and-infer-next-history # Use ctrl-space in menu-select to open a dir and show sub-dirs in the menu
bindkey -M menuselect '^A' send-break # Abort menu selection

bindkey "^[[A" local-history-beginning-search-backward # Go up in local history only, see below
bindkey "^[[B" local-history-beginning-search-forward # Same for down

# Use arrow keys to search local history (using words up to cursor in search)
local-history-beginning-search-backward() {
    zle set-local-history 1
    zle history-beginning-search-backward
    zle set-local-history 0
}
local-history-beginning-search-forward() {
    zle set-local-history 1
    zle history-beginning-search-forward
    zle set-local-history 0
}
zle -N local-history-beginning-search-backward # Sets the above function as a widget so it can be keybound
zle -N local-history-beginning-search-forward 

# Ability to alt-backspace dirs like in bash
backward-kill-dir () {
    local WORDCHARS=${WORDCHARS/\/}
    zle backward-kill-word
}
zle -N backward-kill-dir
bindkey '^[^?' backward-kill-dir

# Copy arg on current line with Alt-m. Like Alt-. but for current line instead of last
# http://chneukirchen.org/blog/archive/2013/03/10-fresh-zsh-tricks-you-may-not-know.html
autoload -Uz copy-earlier-word
zle -N copy-earlier-word
bindkey "^[m" copy-earlier-word

# History file settings
HISTFILE=~/.histfile
HISTSIZE=10000 # Max history size of a session
SAVEHIST=100000 # Max size of histfile

##### Prompt

# ANSI Color escape codes
# ANSI escape codes are interpreted by the terminal
# Zsh requires no-output escape sequences to be surrounded by %{ and %}
# Zsh gives us the escape codes in associative arrays with the "colors" function
autoload -Uz colors && colors 

# Reset
COLOR_OFF=%{$reset_color%}

# Regular colors
RED=%{$fg_no_bold[red]%}
GREEN=%{$fg_no_bold[green]%}
YELLOW=%{$fg_no_bold[yellow]%}
BLUE=%{$fg_no_bold[blue]%}
PURPLE=%{$fg_no_bold[purple]%}
CYAN=%{$fg_no_bold[cyan]%}
WHITE=%{$fg_no_bold[white]%}

# Light (or bold, usually printed as light)
L_RED=%{$fg_bold[red]%}
L_GREEN=%{$fg_bold[green]%}
L_YELLOW=%{$fg_bold[yellow]%}
L_BLUE=%{$fg_bold[blue]%}
L_PURPLE=%{$fg_bold[purple]%}
L_CYAN=%{$fg_bold[cyan]%}
L_WHITE=%{$fg_bold[white]%}

# Variables for PS1 prompt 
TIME24H="%*"
DATE="%D{%m/%d}"
PATH_SHORT="%~"
NEWLINE="
" # Why zsh, why
USERNAME_PROMPT="%n"
HOSTNAME_PROMPT="%m"

# Special function zsh executes before each prompt, see https://zsh.sourceforge.io/Doc/Release/Functions.html#Special-Functions
function precmd {
    PS1="$(get_prompt_str)"
}

# Aliases
alias reloadrc='source ~/.zshrc'
# zsh has global aliases that you can use with the -g option, that will replace the text of the alias at any location in a command, not just the beginning
alias -g gLASTDOWN='$(ls -t ~/Downloads/ | head -n 1)'
alias -g gRSAKEY='~/.ssh/id_rsa.pub'
alias -g gEDKEY='~/.ssh/id_ed25519.pub'
alias -g gWINHOME='/mnt/c/Users/kendall' # For WSL, there's techincally WSLENV but I don't want to deal with finding the right way to parse it right now

# Loading other scripts
source ~/.common.sh
[[ -e ~/.zshrc.local ]] && source ~/.zshrc.local;
[[ -a ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # The instructions for this say it needs to be sourced last
