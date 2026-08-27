#!/usr/bin/env bash
# Create a new project from the template, register it in PROJECTS.md,
# and push it — per CLAUDE.md §3. Run this only after you've confirmed
# (via PROJECTS.md + the user) that no existing project already covers
# the task.
#
# Usage: scripts/new-project.sh <slug> ["one-line summary"]
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <slug> [\"one-line summary\"]" >&2
  exit 1
fi

SLUG="$1"
SUMMARY="${2:-}"
TODAY="$(date +%Y-%m-%d)"
REPO_ROOT="$(git rev-parse --show-toplevel)"
PROJECT_DIR="$REPO_ROOT/projects/$SLUG"
TEMPLATE_DIR="$REPO_ROOT/projects/_TEMPLATE"

if [[ ! "$SLUG" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "Slug should be kebab-case (lowercase letters, digits, hyphens): got '$SLUG'" >&2
  exit 1
fi

if [ -e "$PROJECT_DIR" ]; then
  echo "projects/$SLUG already exists — resume it (read its PROGRESS.md) instead of recreating it." >&2
  exit 1
fi

cd "$REPO_ROOT"
git pull --rebase --autostash

cp -r "$TEMPLATE_DIR" "$PROJECT_DIR"

TITLE="${SUMMARY:-$SLUG}"
cat > "$PROJECT_DIR/README.md" <<EOF
# $TITLE

$( [ -n "$SUMMARY" ] && echo "$SUMMARY" || echo "One or two paragraphs: what this project is, why it exists, and any constraints or preferences the user gave (deadlines, tone, format, tools to use/avoid)." )
EOF

cat > "$PROJECT_DIR/PROGRESS.md" <<EOF
# Progress log

Newest entry on top. See CLAUDE.md §6 for the format.

## $TODAY — bootstrap
Status: active
- created the project via scripts/new-project.sh
- next: fill in README.md and start work
EOF

# Insert a row into PROJECTS.md, replacing the "none yet" placeholder if
# it's still the only row.
python3 - "$SLUG" "$TODAY" "$SUMMARY" "$REPO_ROOT/PROJECTS.md" <<'PYEOF'
import sys

slug, today, summary, path = sys.argv[1:5]
with open(path) as f:
    lines = f.readlines()

row = f"| {slug} | active | {today} | {summary} |\n"
has_placeholder = any(line.strip() == "| _(none yet)_ | | | |" for line in lines)

out = []
done = False
for line in lines:
    if not done and has_placeholder and line.strip() == "| _(none yet)_ | | | |":
        out.append(row)
        done = True
    elif not done and not has_placeholder and line.startswith("|---"):
        out.append(line)
        out.append(row)
        done = True
    else:
        out.append(line)

with open(path, "w") as f:
    f.writelines(out)
PYEOF

git add "projects/$SLUG" PROJECTS.md
git commit -m "$SLUG: create project"
git pull --rebase --autostash
git push

echo "Created and pushed projects/$SLUG"
