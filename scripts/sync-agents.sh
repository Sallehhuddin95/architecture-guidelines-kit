#!/usr/bin/env bash
#
# Sync .opencode/agents/ from .github/agents/ (canonical source of truth).
# Conversion: keep frontmatter description, replace `name:` with `mode: all`.
# Run from the repository root. Fails closed on any missing source file.
set -euo pipefail

SRC_DIR=".github/agents"
DST_DIR=".opencode/agents"

declare -A MAP=(
  ["architect.agent.md"]="architect.md"
  ["documentation.agent.md"]="documentation.md"
  ["refactor.agent.md"]="refactor.md"
  ["reviewer.agent.md"]="reviewer.md"
  ["tester.agent.md"]="tester.md"
  ["expert-angular-developer.agent.md"]="angular-architect.md"
  ["expert-django-developer.agent.md"]="django-architect.md"
  ["expert-express-developer.agent.md"]="express-architect.md"
  ["expert-fastapi-developer.agent.md"]="fastapi-architect.md"
  ["expert-nextjs-developer.agent.md"]="nextjs-architect.md"
  ["expert-react-native-developer.agent.md"]="react-native-architect.md"
)

[ -d "$SRC_DIR" ] || { echo "Missing $SRC_DIR" >&2; exit 1; }
mkdir -p "$DST_DIR"

synced=0
for src in "${!MAP[@]}"; do
  dst="${MAP[$src]}"
  [ -f "$SRC_DIR/$src" ] || { echo "Missing source $SRC_DIR/$src" >&2; exit 1; }
  awk '
    BEGIN { n = 0 }
    /^---$/ { n++; print; next }
    n == 1 && /^name: / { print "mode: all"; next }
    { print }
  ' "$SRC_DIR/$src" > "$DST_DIR/$dst"
  synced=$((synced + 1))
done

echo "Synced $synced agent files ($SRC_DIR -> $DST_DIR)."
