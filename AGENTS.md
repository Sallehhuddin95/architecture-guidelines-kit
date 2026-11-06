# AI Agent Engineering Instructions

This file is the root entry point for coding assistants that read
`AGENTS.md` natively (Cursor, Claude Code, Windsurf, GitHub Copilot,
OpenCode). It binds agent behavior to this repository's governance.
It creates no new policy: it points at the existing sources of truth.

## 1. Authority Hierarchy (Strict Order of Precedence)

When instructions or patterns conflict, follow this exact precedence order:

1. `CONSTITUTION.md` (Non-negotiable repo governance)
2. `docs/adr/` (Accepted Architectural Decision Records)
3. `docs/architecture/` and `docs/shared/` (System boundaries, dependency rules, security, API/error contracts)
4. `docs/backend/`, `docs/frontend/`, `docs/mobile/` (Stack-specific implementation conventions)
5. `specs/` (Feature, API, database, UI, and acceptance specifications)
6. `docs/workflow/` (Operational engineering workflows)
7. `.github/agents/` and `.opencode/agents/` (Role definitions - must enforce rules 1-6, never invent competing policies)

## 2. Mandatory Spec-Driven Workflow

Never write or modify production code for a new feature or behavioral
change without an accompanying specification in `specs/`:

1. **Specify (`/spec.propose`):** Define `proposal.md` and `spec-delta.md`
   with EARS requirements (`WHEN ... THE SYSTEM SHALL ...`) and
   `Given / When / Then` acceptance criteria.
2. **Plan (`/spec.plan`):** Validate module boundaries
   (`docs/architecture/module-boundaries.md`) and dependency direction
   (`docs/architecture/dependency-rules.md`) in `design.md` (drafting a
   `Proposed` ADR inline if structural rules change).
3. **Decompose (`/spec.tasks`):** Break work into test-first atomic steps
   in `tasks.md`.
4. **Implement & Verify (`/spec.verify`):** Write tests first, implement
   the smallest architecture-consistent slice, run static analysis, and
   fold completed deltas back into `specs/`.

## 3. Non-Negotiable Guardrails

- **No Cross-Feature Leakage:** Features must communicate only through
  documented public module interfaces
  (`docs/architecture/module-boundaries.md`).
- **Protected Fields Invariant (`ADR-0004`):** Never trust client payloads
  for ownership, roles, timestamps, or billing/status fields.
- **Error and API Consistency:** All endpoints must follow
  `docs/shared/api-contract.md` and `docs/shared/error-handling.md`.
