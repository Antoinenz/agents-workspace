#!/usr/bin/env bash
# Run at the start of every session, per CLAUDE.md §0.
# Pulls latest, rebasing local work on top, auto-stashing/restoring any
# uncommitted changes so it's always safe to run.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
git pull --rebase --autostash
