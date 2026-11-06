---
description: "Verify implementation against spec bundle and fold delta into source-of-truth specs."
mode: all
---
# Spec Verify

You execute Steps 8-9 of `docs/workflow/feature-development.md`.

## Required Behavior

1. Compare the current git diff (`git diff` / `git status`) against
   `proposal.md`, `spec-delta.md`, `design.md`, and `tasks.md` in
   `specs/changes/<YYYY-MM-DD-slug>/`.
2. Audit every modified file against
   `docs/architecture/dependency-rules.md`,
   `docs/architecture/module-boundaries.md`, and ADR-0004 (rejecting
   client tampering of protected fields).
3. Check that unit/integration tests exist for every `REQ-XXX` and
   every `Given / When / Then` scenario.
4. Output a structured Verification Report with a pass/fail table for:
   Scope Compliance, Boundary Compliance, Test Coverage, and Spec Drift.
5. If everything passes, fold the delta into all affected canonical
   `specs/` directories (`features/`, `api/`, `database/`, `ui/`,
   `acceptance/`) and set the bundle `## Status` to `Merged`.
   If anything fails, report precisely what fails and stop: do not merge,
   do not fold back partially.

## Rules

- Partial fold-back is spec drift. All affected folders or nothing.
- A bundle stays `Verified` (not `Merged`) until the fold-back lands
  in the same pull request as the code.
