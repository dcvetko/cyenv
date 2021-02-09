#!/bin/bash

export CYENV_BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export CYENV_BASE_SCRIPT="workspace_base.sh"
export CYENV_TMUX_SESSION="tmux_session.sh"

alias tm="$CYENV_BASE_DIR/$CYENV_TMUX_SESSION"

cyenv_bash_startup()
{
    if ! [ -x "$(command -v tmux)" ]
    then
        return
    fi

    # Load tmux-session specific environments
    if [ -n "$TMUX" ]
    then
        TMUX_SESSION_NAME=$(tmux display-message -p '#S' 2>/dev/null)
        export CYPROJECT=$TMUX_SESSION_NAME
        if [ $? == "0" ] && [ -f $WORKSPACE_TMUX_ENVS/$TMUX_SESSION_NAME.sh ]
        then
            tput bold
            tput setaf 5
            printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
            echo "** Loading tmux workspace $TMUX_SESSION_NAME"
            tput sgr0
            source $WORKSPACE_TMUX_ENVS/$TMUX_SESSION_NAME.sh
            tput bold
            tput setaf 5
            echo "** Finished loading tmux workspace $TMUX_SESSION_NAME"
            printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
            tput sgr0
        fi
    else
        tmux ls
    fi
}
