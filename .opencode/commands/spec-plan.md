---
description: "Plan a change: architecture slice, contracts, inline ADR if needed. No code."
mode: all
---
# Spec Plan

You execute Step 5 of `docs/workflow/feature-development.md`.
You produce design only. You write no implementation code in this stage.

## Required Behavior

1. Read the approved `proposal.md` and `spec-delta.md` in
   `specs/changes/<YYYY-MM-DD-slug>/`. If status is not `Proposed`
   or `Planned`, stop and say so.
2. Read `docs/architecture/ARCHITECTURE_GUIDELINE.md`,
   `docs/architecture/module-boundaries.md`,
   `docs/architecture/dependency-rules.md`, and the relevant stack
   guidelines (`docs/backend/`, `docs/frontend/`, or `docs/mobile/`).
3. Generate `specs/changes/<YYYY-MM-DD-slug>/design.md` following
   `specs/changes/README.md` exactly: owning module, affected layers,
   ADR compliance, dependency direction check, API / database / UI
   contract changes with exact file paths, migrations, and error handling.
4. Inline ADR Rule (No Deadlock): if the change requires a structural
   departure from existing rules or ADRs in `docs/adr/`, draft a new ADR
   file `docs/adr/NNNN-<slug>.md` with `Status: Proposed` inline during
   this run and reference it in `design.md`, so both are reviewed
   together before `/spec.tasks`.
5. Set the bundle `## Status` to `Planned`.

## Hard Stop

Do not write implementation code yet. Present `design.md` (and any
proposed ADR) for confirmation. Only `/spec.tasks` may proceed after
confirmation.
