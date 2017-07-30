#!/usr/bin/env zsh

#[[ -z "$TMUX" ]] && exec tmux
 
# TMUX
#if which tmux >/dev/null 2>&1; then
    ##if not inside a tmux session, and if no session is started, start a new session
    #test -z "$TMUX" && (tmux attach || tmux new-session)
#fi


# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}'
zstyle :compinstall filename '/home/kendall/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=100000
setopt appendhistory extendedglob
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install

##### Settings
bindkey -e # Emacs mode for line editing

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

function precmd {
    PS1="$(get_prompt_str)"
}

source ~/.common.sh
[[ -e ~/.zshrc.local ]] && source ~/.zshrc.local;
