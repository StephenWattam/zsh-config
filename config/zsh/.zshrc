# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
ZBEEP='\e[?5h\e[?5l'

# Shell Options
# Options:
# append_history: append all zsh terms to history in order of kill, rather than overwriting
# autocd: change dir by typing filepath only
# auto_param_slash: add / to the end of completed directories
# auto_pushd: automatically pushd on cd, to provide a history
# bsd_echo: Make echo behave like 'normal' BSD echo (no escaping by default)
# clobber: usual bash-style > to clobber, >> to append
# extendedglob: support not, more rx globbing
# nocorrect: don't try to correct spelling of commands
# nocorrect_all: Don't try to correct all arguments
# extended_history: save timestamps in history
# nomatch: print an error if a file pattern gives no matches
# nohash_dirs: Do not keep hashes of directories
# nohash_cmds: Do not try to remember commands
# -nohash_list_all: Don't try to hash everything in a command before completion
# list_types: Show filetype in completion menu using a trailing flag
# multios: Allow for multiple redirects by implying 'tee' and 'cat' > one > two | three
# nomail_warning: Disable mail checking
# numeric_glob_sort: Sort things by number if they have a numeric component (not alpha)
# pushd_ignore_dups: Avoid pushing endless copies of the same directory onto the pushd stack
# pushdsilent: Do not echo the stack when push/popd used, it is printed as part of PROMPT anyway
# sh_file_expansion: Expand filenames first in commands
setopt append_history \
    auto_param_slash \
    auto_pushd \
    bsd_echo \
    clobber \
    nocorrect \
    nocorrect_all \
    extended_history \
    nohash_dirs \
    nohash_cmds \
    list_types \
    nomail_warning \
    numeric_glob_sort \
    pushd_ignore_dups \
    sh_file_expansion \
    multios \
    autocd \
    extendedglob \
    nomatch \
    pushdsilent



# Options I probably don't want:
# single_line_zle: Use single-line editing (no "menu ahead")
# verbose: Echo commands before running them
# xtrace: echo commands and their arguments as they are run
# setopt verbose xtrace
# setopt single_line_zle




# The following lines were added by compinstall

# zstyle ':completion:*' completer _list _complete _prefix
# zstyle ':completion:*' file-sort name
# zstyle ':completion:*' format '[%d]'
# zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
# zstyle ':completion:*' match-original both
# zstyle ':completion:*' max-errors 0
# zstyle ':completion:*' preserve-prefix '//[^/]##/'
# zstyle :compinstall filename '/home/extremetomato/.zshrc'
# 
# autoload -Uz compinit
# compinit
# # Disable completion for certain very annoying things
# compdef -d mount
# 

# End of lines added by compinstall





# Configure special keys for moving back/forward
# This is somewhat problematic with ZLE, but this config works
# for rxvtc at the least
bindkey -e      # emacs mode
bindkey "^[[3~" delete-char 
bindkey "^[[5~" forward-word 
bindkey "^[[6~" backward-word 
bindkey "^[[7~" beginning-of-line
bindkey "^[[8~" end-of-line 



# From http://zshwiki.org/home/zle/ircclientlikeinput
# allows me to get a blank line with "down", like irssi
fake-accept-line() {
  if [[ -n "$BUFFER" ]];
  then
    print -S "$BUFFER"
  fi
  return 0
}
zle -N fake-accept-line

down-or-fake-accept-line() {
  if (( HISTNO == HISTCMD )) && [[ "$RBUFFER" != *$'\n'* ]];
  then
    zle fake-accept-line
  fi
  zle .down-line-or-history "$@"
}
# zle -N down-line-or-history down-or-fake-accept-line
zle -N down-or-fake-accept-line

bindkey '^[[B' down-or-fake-accept-line

# ---------


# Want colour, if we can have it

alias ls="ls --color"






# Colours and stuffs
autoload -U colors && colors
# Simple LHS prompt
#
# The prompt displays:
#  the hostname IF $SSH_CONNECTION if set
#  a '+'        if this is a subshell
#  a RED %/#    if (a new bg task has been created with return code other than 20 || any other command causes a non-zero return code)
#  ==
#  The last 20 characters of the path relative to ~
#  running jobs if nonzero (white)

export PROMPT="${SSH_CONNECTION+%B$HOST%(2L.[%L].)%b}%(?..%{$fg[red]%})%#%(?..%{$reset_color%}) " 
export RPROMPT="%20<...<%~%(1j. %B%j%b.)%(?.. %{$fg[red]%}%?%{$reset_color%})"  


