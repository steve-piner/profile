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

# Preferred editor
export EDITOR=emacs

for editor in vim vim.tiny vi emacs; do
    if which $editor > /dev/null; then
        export SVN_EDITOR=$editor
        export GIT_EDITOR=$editor
        break
    fi
done

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar
# Set up PATH

# Add ~/local/bin to the path.
if [ -d "$HOME/local/bin" ]; then
    export PATH="$HOME/local/bin:$PATH"
fi

# Perlbrew
# To initialise, set PERLBREW_ROOT as below and run perlbrew init to
# create the directory.
if [ -f /usr/bin/perlbrew ] && [ -e $HOME/local/perlbrew ]; then
    export PERLBREW_ROOT=$HOME/local/perlbrew
    source ${PERLBREW_ROOT}/etc/bashrc
fi

# Perl local::lib

enable_local_lib() {
    if [ -d "$HOME/local/lib/perl5" ]; then
        PATH="$HOME/local/lib/perl5/bin${PATH+:}${PATH}"; export PATH;
        PERL5LIB="$HOME/local/lib/perl5/lib/perl5${PERL5LIB+:}${PERL5LIB}"; export PERL5LIB;
        PERL_LOCAL_LIB_ROOT="$HOME/local/lib/perl5${PERL_LOCAL_LIB_ROOT+:}${PERL_LOCAL_LIB_ROOT}"; export PERL_LOCAL_LIB_ROOT;
        PERL_MB_OPT="--install_base \"$HOME/local/lib/perl5\""; export PERL_MB_OPT;
        PERL_MM_OPT="INSTALL_BASE=$HOME/local/lib/perl5"; export PERL_MM_OPT;
    else
        echo 'local::lib not configured; could not find ~/local/lib/perl5'
    fi
}

# Do not enable local::lib if perlbrew detected.
# Having a common area for modules across multiple versions of Perl can cause
# modules that have XS components to become mismatched, leading to crashes.
if [ ! -e $HOME/local/perlbrew ] &&  [ -d "$HOME/local/lib/perl5" ]; then
    enable_local_lib
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

# NVM - Node Version Manager
# https://github.com/nvm-sh/nvm
export NVM_DIR="$HOME/.nvm"
# This loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# This loads nvm bash_completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# SP: Removed lesspipe (file unpacking for less)

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Face boxes declare this terminal, but don't know how to support it.
if [ "$TERM" = xterm-256color ]; then
    export TERM=xterm-color
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
else
    color_prompt=
fi

if [ "$color_prompt" = yes ]; then
    ENVIRONMENT=
    if which prompt-environment > /dev/null; then
        ENVIRONMENT=$(prompt-environment)
    else
        case "$HOSTNAME" in
            lovelace|julia|obrien)
                ENVIRONMENT=safe
                ;;
            prole|pustule|morris|branzdevww01|leone|levinson|haynes)
                ENVIRONMENT=caution
                ;;
            *)
                ENVIRONMENT=live
                ;;
        esac
    fi

    HOST_COLOUR=00
    PATH_COLOUR='97;44'
    case "$ENVIRONMENT" in
        safe)
            # Bright white text on green
            HOST_COLOUR='97;42'
            ;;
        test)
            # Bright white text on purple
            HOST_COLOUR='97;45'
            ;;
        uat)
            # Bright white on yellow
            HOST_COLOUR='97;43'
            ;;
        caution)
            # Bright white text on blue
            HOST_COLOUR='97;44'
            # Bright yellow text on black
            PATH_COLOUR='93;40'
            ;;
        *)
            # Bright white text on red
            HOST_COLOUR='97;41'
            ;;
    esac

    if [ "$SUDO_USER" = "" ]; then
        USER_COLOUR=$HOST_COLOUR
    else
        # Bright white on cyan
        USER_COLOUR='97;46'
    fi

    PS1='${debian_chroot:+($debian_chroot)}\[\033['$USER_COLOUR'm\]\u\[\033['$HOST_COLOUR'm\]@\h:\[\033['$PATH_COLOUR'm\]\w\$ \[\033[00m\] '
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

# Start an SSH Agent unless there is one already.
if [ "$SSH_AUTH_SOCK" == "" ]; then
    agent_dir="$HOME/local/var/ssh-agent"
    # Find one of my existing agents.
    # Get the newest one with parent pid 1 (gnome-keyring-daemon also runs an
    # ssh-agent but we can't hook into it)
    agent_pid=$(pgrep -P 1 -n -u $USER ssh-agent)
    # Include $USER so sudo doesn't screw up the agents.
    if [ "$agent_pid" == "" ] || [ ! -f "$agent_dir/env.$USER.$agent_pid" ]
    then
        mkdir -p "$agent_dir"
        env_file=$(mktemp -p "$agent_dir")
        ssh-agent > $env_file
        source $env_file
        mv $env_file "$agent_dir/env.$USER.$SSH_AGENT_PID"
    else
        source "$agent_dir/env.$USER.$agent_pid"
    fi
fi

# Flash the background until a key is pressed.
# Use for indicating a task is complete: sleep 3600; flasher
flasher () {
    while true; do
        printf "\e[?5h"
        sleep 0.1
        printf "\e[?5l"
        read -s -n1 -t1 && break
    done
}

# If directory finding script is available, create 'd' function to use
# it.
if [ -f $HOME/local/bin/dir-match.pl ]; then
    d () {
        match=$(perl $HOME/local/bin/dir-match.pl $*)
        if [ ! -z "$match" ]; then
            cd "$match"
        fi
    }
fi

#  ~/unix-profile/.installed should be removed by a push from a remote
#  server, which likely indicates an update.
if [ ! -e $HOME/unix-profile/.installed ]; then
    echo -e '\e[97;42m There is a unix-profile update to apply \e[0m'
fi

if [ ~/.bashrc -ot ~/unix-profile/home/.bashrc ]; then
	echo -e '\e[1;93;40m Updated profile available \e[0m'
	echo 'To update, run: cd unix-profile && ./install.pl'
fi

# Any local environment changes can be added to this file
if [ -f $HOME/.local-env ]; then
    . $HOME/.local-env
fi
