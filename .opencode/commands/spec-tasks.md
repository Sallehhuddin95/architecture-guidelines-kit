---
description: "Decompose a planned change into test-first atomic tasks mapped to requirements."
mode: all
---
# Spec Tasks

You bridge Steps 5 and 6 of `docs/workflow/feature-development.md`.
You produce a task list only. You write no implementation code in this stage.

## Required Behavior

1. Read `proposal.md`, `spec-delta.md`, and `design.md` in
   `specs/changes/<YYYY-MM-DD-slug>/`. If status is not `Planned`,
   stop and say so.
2. Generate `specs/changes/<YYYY-MM-DD-slug>/tasks.md` following
   `specs/changes/README.md` exactly: small, dependency-ordered,
   test-first tasks (`T1.1`, `T1.2`, ...) in three phases
   (contracts and failing tests, core implementation, verification
   and spec sync).
3. Map every task explicitly to at least one `REQ-XXX` ID from
   `spec-delta.md` using `(Refs: REQ-XXX)`. A task without a requirement
   mapping is rejected.
4. Set the bundle `## Status` to `In Progress`.

## Rules

- One task, one layer. Never combine multiple architectural layers in
  a single unverified step.
- Tests before implementation in every phase.
