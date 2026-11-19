#!/usr/bin/env bash
# Moves one workspace off Trail of Bits' devcontainer, so it can be tried with
# sbx while other workspaces keep using devc. Run it from the workspace:
#
#   cd ~/workspace/myproject && ~/workspace/claude-container/remove_trailofbits.sh
#
# 1. copies the container's Claude sessions to the host's ~/.claude/projects (devc sync)
# 2. removes the container, its volumes (Claude login, gh login, shell history)
#    and its image (devc destroy)
# 3. renames .devcontainer/ to .devcontainer.trailofbits/, so going back is:
#    mv .devcontainer.trailofbits .devcontainer && devc up
# devc itself stays installed.

set -euo pipefail

dir="$(cd "${1:-.}" && pwd)"
backup="$dir/.devcontainer.trailofbits"

say() { printf '\033[0;34m[remove]\033[0m %s\n' "$1"; }
die() { printf '\033[0;31m[remove]\033[0m %s\n' "$1" >&2; exit 1; }

[ -d "$dir/.devcontainer" ] || die "no .devcontainer/ in $dir"
[ ! -e "$backup" ] || die "$backup already exists; remove it first"
command -v devc >/dev/null || die "devc not found: it is needed to remove the container"

say "workspace: $dir"
say "this copies its Claude sessions to ~/.claude/projects, then deletes its container,"
say "volumes (Claude and gh logins, shell history) and image, and renames .devcontainer/"
read -r -p "Continue? [y/N] " reply
[[ "$reply" =~ ^[Yy]$ ]] || { say "aborted"; exit 0; }

cd "$dir"
devc sync "$(basename "$dir")" --trusted || say "no sessions copied (no container found)"
devc destroy -f
mv .devcontainer "$backup"

say "done. Try sbx here with: sbx run claude"
say "to go back: mv .devcontainer.trailofbits .devcontainer && devc up"
