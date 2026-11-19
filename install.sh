#!/usr/bin/env bash
# Sets up a host to run Claude Code in Trail of Bits' devcontainer, with `cl`
# for background sessions. Safe to re-run: it updates what is already there.
#
#   ./install.sh
#
# Installs:
#   - jq, dtach (apt) and the devcontainer CLI (npm), if missing
#   - trailofbits/claude-code-devcontainer in ~/.claude-devcontainer, and `devc`
#   - `cl` in ~/.local/bin, linked to this repo
# Docker is required but not installed by this script.

set -euo pipefail

UPSTREAM="https://github.com/trailofbits/claude-code-devcontainer"
DEVC_DIR="${DEVC_DIR:-$HOME/.claude-devcontainer}"
BIN_DIR="$HOME/.local/bin"
REPO_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

say() { printf '\033[0;34m[install]\033[0m %s\n' "$1"; }
die() { printf '\033[0;31m[install]\033[0m %s\n' "$1" >&2; exit 1; }

command -v docker >/dev/null || die "docker not found: install Docker first (https://docs.docker.com/engine/install/)"
command -v git >/dev/null || die "git not found"

missing=()
for pkg in jq dtach; do command -v "$pkg" >/dev/null || missing+=("$pkg"); done
if [ ${#missing[@]} -gt 0 ]; then
  command -v apt-get >/dev/null || die "install ${missing[*]} with your package manager, then re-run"
  say "installing ${missing[*]}"
  sudo apt-get update -qq && sudo apt-get install -y -qq "${missing[@]}"
fi

if ! command -v devcontainer >/dev/null; then
  command -v npm >/dev/null || die "npm not found: install Node.js, then re-run (needed for @devcontainers/cli)"
  say "installing @devcontainers/cli"
  npm install -g @devcontainers/cli
fi

if [ -d "$DEVC_DIR/.git" ]; then
  say "updating $DEVC_DIR"
  git -C "$DEVC_DIR" pull --ff-only --quiet
else
  say "cloning $UPSTREAM into $DEVC_DIR"
  git clone --quiet "$UPSTREAM" "$DEVC_DIR"
fi
"$DEVC_DIR/install.sh" self-install

mkdir -p "$BIN_DIR"
ln -sf "$REPO_DIR/bin/cl" "$BIN_DIR/cl"
say "linked $BIN_DIR/cl -> $REPO_DIR/bin/cl"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) say "add to your shell profile: export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac
say "done: devc $(git -C "$DEVC_DIR" rev-parse --short HEAD)"
