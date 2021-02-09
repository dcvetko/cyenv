Simple development tool to setup workspace environments (shell and tmux).

# How-To

## bashrc

Set the following two variables:
```
export WORKSPACE_TMUX_ENVS="<PATH>"
export WORKSPACE_TMUX_NOTES="<PATH>"
```

Source the main bash script and call the startup function (at the end of the bashrc file):
```
source <INSTALL_OR_CHECKOUT_DIR>/cyenv.sh
cyenv_bash_startup
```

## Environment scripts (in WORKSPACE_TMUX_ENVS)

The following variables (TE = TMUX Environment) are supported:

  - TE_GIT_WB:           The git working branch (gwb)
  - TE_PROJECT_ROOT:     The root directory for the current project (cdp)
  - TE_PROJECT_DOCS:     A weblink to the project docs (wsd)
  - TE_PROJECT_TASKS:    A weblink to the project tasks (wst)
  - TE_BOOKMARKS_FILE    A list of directories

The following functions can be used to "extend" functionality:
  - wss_project:       Extend workspace setup (wss)
  - wsi_project:       Extend workspace info (wsi)

cdb will list all bookmarks with fzf.

In case the TE_GIT_WB is checked out as a worktree (based on branch and path
name as fallback), the worktree path can overwrite the root directory. Use
TE_GIT_WB_OVERWRITES_PROJECT_ROOT=1 before sourcing this script.

The following "basic" functions are supported if implemented:
  - wsci:              Trigger a CI build

After setting these variables and functions, source the base script:
```
source $CYENV_BASE_DIR/workspace_base.sh
```

## Usage in console

```
tm l
tm <environment name>
tm n
tm k
```
