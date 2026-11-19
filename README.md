# claude-container

One script to set up an Ubuntu host for Claude Code in
[Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) (`sbx`), plus `cl` to keep several Claude sessions
running in the background.

Each sandbox is a microVM with its own kernel. Outbound traffic is deny-by-default through a host-side proxy, and
credentials stay on the host: the proxy adds them to requests
([security](https://docs.docker.com/ai/sandboxes/security)). Local use is free.

## Install

```bash
git clone <this repo> ~/workspace/claude-container
~/workspace/claude-container/install.sh
sbx login                  # first time only
```

Needs Ubuntu 24.04+ (not derivatives) with KVM turned on
([requirements](https://docs.docker.com/ai/sandboxes/install/)). The script adds your user to the `kvm` group,
adds Docker's apt repository, installs `docker-sbx` and `dtach`, and links `cl` into `~/.local/bin`. Re-run it to
upgrade.

## Use

```bash
cd ~/workspace/myproject
cl myproject create        # background session (a login shell); start Claude in it:
sbx run claude             # runs claude --dangerously-skip-permissions in a sandbox for this folder
# Ctrl-\ detaches; Claude keeps running
cl                         # list sessions
cl myproject               # attach again
```

Running `sbx run claude` again in the same folder reconnects to the same sandbox; `sbx ls` lists them, `sbx stop`
and `sbx rm` stop and remove one. Parallel agents in one sandbox: `sbx run --clone claude . -- agents`
([Claude Code in sbx](https://docs.docker.com/ai/sandboxes/agents/claude-code/)).

## Skills

Sandboxes don't read the host's `~/.claude`. Skills go through a shared store on the host
(`~/.local/state/sandboxes/sandboxes/agent-skills`), mounted read-only into new sandboxes. `sbx skills import`
copies skills in from `~/.claude/skills` and other agents' folders; re-run it after changing a skill. The feature
is experimental ([agent skills](https://docs.docker.com/ai/sandboxes/workflows/agent-skills/)).
