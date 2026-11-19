#!/usr/bin/env bash
# Sets up an Ubuntu host to run Claude Code in Docker Sandboxes (`sbx`, a microVM
# per sandbox). Safe to re-run: it upgrades what is already there.
#
#   ./install.sh
#
# Does only this:
#   - checks for Ubuntu 24.04+ and KVM
#   - adds you to the kvm group
#   - adds Docker's apt repository and installs `docker-sbx` (Docker Engine not needed)
#   - runs `sbx login` on the first install
# Requires Ubuntu 24.04+ and KVM: https://docs.docker.com/ai/sandboxes/install/

set -euo pipefail

OS_RELEASE="${OS_RELEASE:-/etc/os-release}"
KVM_DEV="${KVM_DEV:-/dev/kvm}"

say() { printf '\033[0;34m[install]\033[0m %s\n' "$1"; }
die() { printf '\033[0;31m[install]\033[0m %s\n' "$1" >&2; exit 1; }

# shellcheck disable=SC1090
. "$OS_RELEASE"
[ "${ID:-}" = ubuntu ] || die "Docker Sandboxes supports Ubuntu 24.04+ only (found ${ID:-unknown}; derivatives such as Mint and Pop!_OS are not supported)"
[ "$(printf '%s\n' 24.04 "$VERSION_ID" | sort -V | head -1)" = 24.04 ] || die "Docker Sandboxes needs Ubuntu 24.04 or later (found $VERSION_ID)"
[ -e "$KVM_DEV" ] || die "$KVM_DEV not found: turn on hardware virtualization (VT-x/AMD-V) in the BIOS; 'kvm-ok' diagnoses it"

relogin=false
if ! id -nG "$USER" | tr ' ' '\n' | grep -qx kvm; then
  say "adding $USER to the kvm group"
  sudo usermod -aG kvm "$USER"
  relogin=true
fi

if command -v sbx >/dev/null; then
  say "upgrading docker-sbx"
  sudo apt-get update -qq && sudo apt-get install -y -qq --only-upgrade docker-sbx
else
  say "adding Docker's apt repository and installing docker-sbx"
  script="$(mktemp)"
  trap 'rm -f "$script"' EXIT
  curl -fsSL https://get.docker.com -o "$script"
  sudo REPO_ONLY=1 sh "$script"
  sudo apt-get install -y -qq docker-sbx
  say "logging in to Docker Sandboxes"
  sbx login
fi

$relogin && say "sign out and back in (or run 'newgrp kvm') so the kvm group applies"
say "done"
