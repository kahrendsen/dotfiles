
[[ -z "$TMUX" ]] && exec tmux
 
# TMUX
if which tmux >/dev/null 2>&1; then
    #if not inside a tmux session, and if no session is started, start a new session
    test -z "$TMUX" && (tmux attach || tmux new-session)
fi


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
source common.sh
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/home/kendall/source/buddy-2.4/src/.libs
