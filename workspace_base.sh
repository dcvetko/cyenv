#!/bin/bash

if [ -z $TE_WSS_CALLED ]
then
    TE_WSS_CALLED=0
fi

#-----------------------------------------------------------------------#

WORKTREE_PATH=""

#-----------------------------------------------------------------------#

__print_seperator()
{
    local columns=$(tput cols)
    printf '%0.s-' $(seq 1 $columns)
}

#-----------------------------------------------------------------------#

__browser_open()
{
    # TODO DC: check OS
    firefox "$@"
}

#-----------------------------------------------------------------------#

__print_info()
{
    echo -e "**** $@"
}

#-----------------------------------------------------------------------#

__gwb()
{
    if [ "$WORKTREE_PATH" != "" ] && [ -d $WORKTREE_PATH ]
    then
        __print_info "gwb: Found ${c_bold}worktree${c_reset} at $WORKTREE_PATH - switching directory..."
        cd $WORKTREE_PATH
    fi

    if [[ -n $(git status -uno --porcelain) ]]
    then
        __print_info "gwb: Working directory is ${c_bold}dirty${c_reset}. Not switching branch."
    else
        __print_info "gwb: Switching ${c_bold}branch${c_reset} to $TE_GIT_WB"
        git checkout $TE_GIT_WB
    fi
}

#-----------------------------------------------------------------------#

__init_worktree()
{
    if [ -z $TE_PROJECT_ROOT ] || [ -z $TE_GIT_WB ]
    then
        return
    fi

    cd $TE_PROJECT_ROOT
    if [ ! -d ".git" ]
    then
        return
    fi

    # Worktree path by branch reference
    git worktree list --porcelain | grep -q "^branch.*$TE_GIT_WB"
    if [ "$?" == "0" ]
    then
        WORKTREE_PATH=$(git worktree list --porcelain | grep -B2 "^branch.*$TE_GIT_WB" | head -1 | awk -F"worktree " '{print $2}')
    fi

    # Worktree path by path name as fallback
    if [ "$WORKTREE_PATH" == "" ]
    then
        git worktree list --porcelain | grep "worktree " | grep -q "$TE_GIT_WB"
        if [ "$?" == "1" ]
        then
            return
        fi
        WORKTREE_PATH=$(git worktree list --porcelain | grep "worktree " | grep "$TE_GIT_WB" | awk -F"worktree " '{print $2}')
    fi

    if [ "$TE_GIT_WB_OVERWRITES_PROJECT_ROOT" == "1" ] && [ -d $WORKTREE_PATH ]
    then
        TE_PROJECT_ROOT=$WORKTREE_PATH
        __print_info "Overwriting project root path with git worktree!"
    fi
}

#-----------------------------------------------------------------------#

__make_aliases()
{
    if [ ! -z $TE_GIT_WB ]
    then
        alias gwb="__gwb"
    fi

    if [ ! -z $TE_PROJECT_ROOT ]
    then
        alias cdp="cd $TE_PROJECT_ROOT"
    fi

    if [ ! -z $TE_PROJECT_DOCS ]
    then
        alias wsd="__browser_open $TE_PROJECT_DOCS"
    fi

    if [ ! -z $TE_PROJECT_TASKS ]
    then
        alias wst="__browser_open $TE_PROJECT_TASKS"
    fi
}

#-----------------------------------------------------------------------#

__print_alias_info()
{
    if [ ! -z $TE_GIT_WB ]
    then
        __print_info "Working branch (or worktree) should be" \
                     "${c_bold}$TE_GIT_WB${c_reset}. Use ${c_bold}gwb${c_reset}" \
                     "to checkout."
    fi

    if [ ! -z $TE_PROJECT_ROOT ]
    then
        __print_info "Project root set to ${c_bold}$TE_PROJECT_ROOT${c_reset}." \
                     "Use ${c_bold}cdp${c_reset}."
    fi

    if [ ! -z $TE_PROJECT_DOCS ]
    then
        local BASE_URL=$(echo $TE_PROJECT_DOCS | cut -d'/' -f3)
        __print_info "Use ${c_bold}wsd${c_reset} to view project docs ($BASE_URL)"
    fi

    if [ ! -z $TE_PROJECT_TASKS ]
    then
        local BASE_URL=$(echo $TE_PROJECT_TASKS | cut -d'/' -f3)
        __print_info "Use ${c_bold}wst${c_reset} to view project tasks ($BASE_URL)"
    fi
}

#-----------------------------------------------------------------------#

cdb()
{
    if [ -f $TE_BOOKMARKS_FILE ]
    then
        local DIR=$(envsubst < $TE_BOOKMARKS_FILE | fzf-tmux)
        cd "$DIR"
    else
        __print_info "Unable to find ${c_bold}bookmarks file${c_reset}"
    fi
}

#-----------------------------------------------------------------------#

# Workspace setup. Extend via wss_project in project_tmux_env
wss()
{
    type wss_project &>/dev/null && wss_project
    TE_WSS_CALLED=1
}

#-----------------------------------------------------------------------#

wsi()
{
    if [ "$TE_WSS_CALLED" == "1" ]
    then
        __print_info "Workspace setup was already called!"
    else
        __print_info "Use ${c_bold}wss${c_reset} to setup workspace"
    fi
    __print_info "Use ${c_bold}wsi${c_reset} to re-print workspace info"
    __print_seperator
    __print_info "Running on ${c_bold}$(hostname)${c_reset}"
    __print_info "Display is ${c_bold}$DISPLAY${c_reset}"
    __print_seperator
    if [ ! -z $WORKTREE_PATH ]
    then
        __print_info "Found checked-out ${c_bold}worktree${c_reset} at $WORKTREE_PATH"
    fi
    __print_alias_info
    type wsci &>/dev/null && __print_info "Use ${c_bold}wsci${c_reset} to trigger a CI build"
    __print_seperator
    type wsi_project &>/dev/null && wsi_project
}

#-----------------------------------------------------------------------#

__init_worktree
__make_aliases
wsi
