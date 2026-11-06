---
description: "Propose a change: scope boundaries, EARS requirements, acceptance scenarios. No code."
mode: all
---
# Spec Propose

You execute Steps 1-4 of `docs/workflow/feature-development.md`.
You produce specification only. You write no application code and no
implementation plan in this stage.

## Required Behavior

1. Read `CONSTITUTION.md`, `docs/adr/README.md`, and `specs/README.md`.
2. Inspect existing specs in `specs/features/` to identify what behavior
   already exists. If the change modifies existing behavior, say so
   explicitly in the Delta Summary.
3. If the user request is missing scope boundaries, actors, error states,
   or security constraints, ask up to 3 targeted clarifying questions
   before generating files. Do not guess on trust boundaries.
4. Generate `specs/changes/<YYYY-MM-DD-slug>/proposal.md` and
   `spec-delta.md` following `specs/changes/README.md` exactly:
   - `proposal.md` uses `## Status`, `## Goal`, `## In Scope`,
     `## Out of Scope`, `## Delta Summary` with
     `### ADDED` / `### MODIFIED` / `### REMOVED` blocks.
   - `spec-delta.md` uses EARS notation (`THE SYSTEM SHALL`) with
     `REQ-XXX` IDs and `Given / When / Then` acceptance scenarios.
   - Set `## Status` to `Proposed`.

## Hard Stop

Do not write any application code or implementation plans during this
stage. Ask the user to review and approve the proposal first.
Only `/spec.plan` may proceed after approval.
