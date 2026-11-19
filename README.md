# claude-container

One script to set up an Ubuntu host for Claude Code in
[Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) (`sbx`).

Each sandbox is a microVM with its own kernel. Outbound traffic is deny-by-default through a host-side proxy, and
credentials stay on the host: the proxy adds them to requests
([security](https://docs.docker.com/ai/sandboxes/security)). Local use is free.

## Install

```bash
git clone <this repo> ~/workspace/claude-container
~/workspace/claude-container/install.sh
```

Needs Ubuntu 24.04+ (not derivatives) with KVM turned on
([requirements](https://docs.docker.com/ai/sandboxes/install/)). The script does only this: checks those, adds your user to the
`kvm` group, adds Docker's apt repository, installs `docker-sbx`, and runs `sbx login` the first time. Re-run it to
upgrade `docker-sbx`.

## Use

```bash
cd ~/workspace/myproject
sbx run claude             # runs claude --dangerously-skip-permissions in a sandbox for this folder
```

Running `sbx run claude` again in the same folder reconnects to the same sandbox; `sbx ls` lists them, `sbx stop`
and `sbx rm` stop and remove one. Parallel agents in one sandbox: `sbx run --clone claude . -- agents`
([Claude Code in sbx](https://docs.docker.com/ai/sandboxes/agents/claude-code/)).

## Moving a workspace off Trail of Bits' devcontainer

One workspace at a time; the others keep using `devc`:

```bash
cd ~/workspace/myproject
~/workspace/claude-container/remove_trailofbits.sh
```

It copies the container's Claude sessions to `~/.claude/projects` (`devc sync`), deletes the container, its
volumes and image (`devc destroy`), and renames `.devcontainer/` to `.devcontainer.trailofbits/`. To go back:
`mv .devcontainer.trailofbits .devcontainer && devc up`, then log in again.

## Background sessions with `cl` (optional)

If a Claude session in `sbx` doesn't survive closing the terminal, `bin/cl` keeps it in a dtach session.
It isn't installed by `install.sh`:

```bash
sudo apt install dtach && ln -s ~/workspace/claude-container/bin/cl ~/.local/bin/cl
cl myproject create        # a login shell you can leave; run `sbx run claude` in it
# Ctrl-\ detaches; Claude keeps running
cl                         # list sessions
cl myproject               # attach again
```

## Skills

Sandboxes don't read the host's `~/.claude`. Skills go through a shared store on the host
(`~/.local/state/sandboxes/sandboxes/agent-skills`), mounted read-only into new sandboxes. `sbx skills import`
copies skills in from `~/.claude/skills` and other agents' folders; re-run it after changing a skill. The feature
is experimental ([agent skills](https://docs.docker.com/ai/sandboxes/workflows/agent-skills/)).
