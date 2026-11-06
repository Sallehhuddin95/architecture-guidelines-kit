#!/usr/bin/env bash
#
# Validate spec schemas: canonical specs/features/ files and
# specs/changes/ four-file bundles (proposal/spec-delta/design/tasks).
# Skips README templates and files marked <!-- sdd-legacy -->.
# Usage: bash scripts/validate-specs.sh [SPECS_ROOT]  (default: specs)
set -euo pipefail

SPECS_ROOT="${1:-specs}"
EXIT_CODE=0

require_sections() {
  local file="$1"
  shift
  for section in "$@"; do
    if ! grep -Eq "^${section}([[:space:]]|$)" "$file"; then
      echo "[FAIL] $file is missing required section: ${section}"
      EXIT_CODE=1
    fi
  done
}

echo "Validating specifications in ${SPECS_ROOT}/..."

# 1. Validate canonical feature specs in ${SPECS_ROOT}/features/
while IFS= read -r -d '' file; do
  [[ "$(basename "$file")" == "README.md" ]] && continue
  if grep -q "<!-- sdd-legacy -->" "$file"; then
    echo "[SKIP] $file is marked sdd-legacy."
    continue
  fi
  require_sections "$file" "## Status" "## Goal" "## Out of Scope" "## Error and Empty States" "## Acceptance Criteria"
  if ! grep -Eq "SHALL|Given|When|Then" "$file"; then
    echo "[FAIL] $file must contain EARS ('SHALL') or Gherkin ('Given/When/Then') testable criteria."
    EXIT_CODE=1
  fi
done < <(find "${SPECS_ROOT}/features" -type f -name "*.md" -print0 2>/dev/null || true)

# 2. Validate multi-file change bundles in ${SPECS_ROOT}/changes/ by file type
while IFS= read -r -d '' file; do
  base="$(basename "$file")"
  case "$base" in
    README.md)
      continue
      ;;
    proposal.md)
      require_sections "$file" "## Status" "## Goal" "## In Scope" "## Out of Scope" "## Delta Summary"
      if ! grep -Eq "^### (ADDED|MODIFIED|REMOVED)" "$file"; then
        echo "[FAIL] $file must contain at least one ### ADDED, ### MODIFIED, or ### REMOVED delta block."
        EXIT_CODE=1
      fi
      dir="$(dirname "$file")"
      if [ ! -f "$dir/spec-delta.md" ]; then
        echo "[FAIL] $file has no sibling spec-delta.md in $dir."
        EXIT_CODE=1
      fi
      if grep -Eq "^(Planned|In Progress|Verified|Merged)$" "$file"; then
        for sibling in design.md tasks.md; do
          if [ ! -f "$dir/$sibling" ]; then
            echo "[FAIL] $file is past proposal stage but $dir/$sibling is missing."
            EXIT_CODE=1
          fi
        done
      fi
      ;;
    spec-delta.md)
      require_sections "$file" "## Formal Requirements" "## Error and Empty States" "## Acceptance Criteria"
      if ! grep -Eq "SHALL" "$file"; then
        echo "[FAIL] $file must contain EARS ('SHALL') formal requirements."
        EXIT_CODE=1
      fi
      if ! grep -Eq "Given|When|Then" "$file"; then
        echo "[FAIL] $file must contain Gherkin ('Given/When/Then') acceptance scenarios."
        EXIT_CODE=1
      fi
      ;;
    design.md)
      require_sections "$file" "## Architecture Alignment" "## Contract Changes"
      ;;
    tasks.md)
      if ! grep -Eq '^- \[[ xX]\] [*]*T[0-9]+\.[0-9]+:[*]*' "$file"; then
        echo "[FAIL] $file must contain numbered task checkboxes (e.g., '- [ ] T1.1:')."
        EXIT_CODE=1
      fi
      if ! grep -Eq 'Refs: .*REQ-[0-9]+' "$file"; then
        echo "[FAIL] $file must map tasks to requirement IDs (e.g., 'Refs: REQ-001')."
        EXIT_CODE=1
      fi
      ;;
  esac
done < <(find "${SPECS_ROOT}/changes" -type f -name "*.md" -print0 2>/dev/null || true)

if [[ $EXIT_CODE -eq 0 ]]; then
  echo "[OK] All feature and change specifications in ${SPECS_ROOT}/ passed validation."
fi

exit $EXIT_CODE
