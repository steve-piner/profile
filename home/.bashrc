# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return
# This is the same test, according to bash(1)
case $- in
    *i*) ;;
    *) return;;
esac

# SP: No duplicates lines in history (only)
# See bash(1) for more options
HISTCONTROL=ignoredups

# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"


# Allow group read and write too.
umask 002

# Don't attempt to complete when I hit tab on an empty command line.
shopt -s no_empty_cmd_completion

# Go figure. I've got used to it.
export SVN_EDITOR=vim

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# SP: Removed lesspipe (file unpacking for less)

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Face boxes declare this terminal, but doesn't know how to support it.
if [ "$TERM" = xterm-256color ]; then
    export TERM=xterm-color
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    HOST_COLOUR=00
    PATH_COLOUR='01;37;44'
    case "$HOSTNAME" in
        lovelace|julia|obrien)
            # Bold white text on green
            HOST_COLOUR='01;97;42'
            ;;
        prole|pustule|morris|branzdevww01|leone|levinson)
            # Bold white text on blue
            HOST_COLOUR='01;97;44'
            # Bold yellow text on black
            PATH_COLOUR='01;93;40'
            ;;
        *)
            # Bold white text on red
            HOST_COLOUR='01;97;41'
            ;;
    esac
    PS1='${debian_chroot:+($debian_chroot)}\[\033['$HOST_COLOUR'm\]\u@\h:\[\033[00m\]\[\033['$PATH_COLOUR'm\]\w\$ \[\033[00m\] '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# SP: Remove ls colours and aliases

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Add ~/local/bin to the path.
if [ -d "$HOME/local/bin" ]; then
    export PATH="$HOME/local/bin:$PATH"
fi

# Perlbrew
if [ -f /usr/bin/perlbrew ] && [ -e $HOME/local/perlbrew ]; then
    export PERLBREW_ROOT=$HOME/local/perlbrew
    source ${PERLBREW_ROOT}/etc/bashrc
fi

# Perl local::lib
if [ -d "$HOME/local/lib/perl5" ]; then
    PATH="$HOME/local/lib/perl5/bin${PATH+:}${PATH}"; export PATH;
    PERL5LIB="$HOME/local/lib/perl5/lib/perl5${PERL5LIB+:}${PERL5LIB}"; export PERL5LIB;
    PERL_LOCAL_LIB_ROOT="$HOME/local/lib/perl5${PERL_LOCAL_LIB_ROOT+:}${PERL_LOCAL_LIB_ROOT}"; export PERL_LOCAL_LIB_ROOT;
    PERL_MB_OPT="--install_base \"$HOME/local/lib/perl5\""; export PERL_MB_OPT;
    PERL_MM_OPT="INSTALL_BASE=$HOME/local/lib/perl5"; export PERL_MM_OPT;
fi

# Rakudobrew
if [ -d "$HOME/.rakudobrew/bin" ]; then
    export "PATH=$HOME/.rakudobrew/bin:$PATH"
fi

# Remove the magic behaviour that makes right-alt differ from left-alt.
# Now done with a startup application.
#xmodmap -e 'remove mod5 = Alt_R'

# Disable the overlay scrollbar
# Now done with dconf-editor, so don't need the line below
#export GTK_OVERLAY_SCROLLING=0

## Include Drush bash customizations.
#if [ -f "/home/steve/.drush/drush.bashrc" ] ; then
#  source /home/steve/.drush/drush.bashrc
#fi

# Include Drush completion.
if [ -f "/home/steve/.drush/drush.complete.sh" ] ; then
  source /home/steve/.drush/drush.complete.sh
fi

## Include Drush prompt customizations.
#if [ -f "/home/steve/.drush/drush.prompt.sh" ] ; then
#  source /home/steve/.drush/drush.prompt.sh
#fi

# Start an SSH Agent unless there is one already.
if [ "$SSH_AUTH_SOCK" == "" ]; then
    agent_dir="$HOME/local/var/ssh-agent"
    # Find one of my existing agents.
    # Get the last one, as it is more likely to have an environment file.
    agent_pid=$(pgrep -u $USER ssh-agent | tail -n 1)
    if [ "$agent_pid" == "" ] || [ ! -f "$agent_dir/env.$agent_pid" ]; then
        mkdir -p "$agent_dir"
        env_file=$(mktemp -p "$agent_dir")
        ssh-agent > $env_file
        source $env_file
        mv $env_file "$agent_dir/env.$SSH_AGENT_PID"
    else
        source "$agent_dir/env.$agent_pid"
    fi
fi

# Flash the background until a key is pressed.
# Use for indicating a task is complete: sleep 3600; flasher
flasher () {
    while true; do
        printf \\e[?5h
        sleep 0.1
        printf \\e[?5l
        read -s -n1 -t1 && break
    done
}


