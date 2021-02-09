#!/bin/bash

new_session()
{
    tmux new-session -A -s "$1" -d -n "$2" $CHDIR_OPTION
}

new_window()
{
    tmux new-window -n "$1" $CHDIR_OPTION
}

split_window()
{
    tmux split-window -h $CHDIR_OPTION
}

select_window()
{
    tmux selectw -t $1
}

attempt_to_attach()
{
    tmux list-sessions | grep -q $1
    if [ $? == "0" ]
    then
        tmux attach-session -t $1
        exit $?
    fi
}

attach()
{
    tmux -2 attach-session -d
}

list_sessions()
{
    echo "** Running sessions:"
    tmux list-sessions

    if [ -d $WORKSPACE_TMUX_ENVS ]
    then
        echo "** Available environments:"
        ls -1 $WORKSPACE_TMUX_ENVS/*.sh
    fi
    exit 0
}

edit_session_notes()
{
    local SESSION=$(tmux display-message -p '#S')
    if [ $? == "0" ]
    then
        vim $WORKSPACE_TMUX_NOTES/$SESSION.md
        exit $?
    fi
    echo "Not in a session..."
    exit 1
}

kill_tmux()
{
    pkill -9 tmux
    exit $?
}

set_chdir_option()
{
    VERSION=$(tmux -V)
    TMUXNEW=0

    if [[ $VERSION == *"tmux 2."* ]]
    then
        TMUXNEW=1
    fi

    CHDIR_OPTION="-c $HOME"
    if [ "$TMUXNEW" == "0" ]
    then
        cd $HOME
        CHDIR_OPTION=""
    fi
}

set_chdir_option

if [ "$1" == "l" ] || [ -z $1 ]
then
    list_sessions
elif [ "$1" == "n" ]
then
    edit_session_notes
elif [ "$1" == "k" ]
then
    kill_tmux
fi

attempt_to_attach $1

new_session $1 "main"
new_window     "secondary"
new_window     "build-A"

select_window 2
split_window

select_window 3
split_window

select_window 1
attach

