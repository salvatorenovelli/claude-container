# claude-container

One script to set up a host for Claude Code in
[Trail of Bits' devcontainer](https://github.com/trailofbits/claude-code-devcontainer), plus `cl` to keep
several Claude sessions running in the background.

Upstream is cloned, not forked: this repo holds no copy of the container, so `devc update` (or re-running
`install.sh`) is how it stays current.

## Install

```bash
git clone <this repo> ~/workspace/claude-container
~/workspace/claude-container/install.sh
```

Needs Docker and git. Installs `jq`, `dtach` (apt) and `@devcontainers/cli` (npm) if missing, clones upstream to
`~/.claude-devcontainer`, installs `devc` and links `cl` into `~/.local/bin`. Re-run it to update.

## Use

```bash
cd ~/workspace/myproject
devc .                                                        # first time: copy the template, start it
devc mount ~/workspace/claude-skills /home/vscode/.claude/skills   # optional: your shared skills

cl myproject create        # background session (a login shell); start Claude in it:
devc up && devc exec bash -lc 'claude -c; exec $SHELL -l'
# Ctrl-\ detaches; Claude keeps running
cl                         # list sessions
cl myproject               # attach again
```

## Updating a project's container

```bash
./install.sh               # pulls upstream
cd ~/workspace/myproject
devc template .            # overwrite .devcontainer/ with upstream; keeps mounts added with `devc mount`
devc rebuild
```
