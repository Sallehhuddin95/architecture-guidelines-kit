# Change Bundles

This folder holds Active Change Proposals: in-flight feature additions,
modifications, or removals. Each change lives in its own directory:

`changes/<YYYY-MM-DD-change-slug>/`

A change directory holds a four-file bundle. All four files are required
for non-trivial features or brownfield changes. Trivial changes
(single-file fix with no behavior change) may use `proposal.md` alone
with reviewer approval.

Template headings below are normative: `scripts/validate-specs.sh`
enforces them in CI. Do not rename sections.

---

## File 1: proposal.md (Intent, Scope, and Delta Summary)

```markdown
# Change Proposal: [Short Descriptive Title]

## Status
Draft | Proposed | Planned | In Progress | Verified | Merged

## Goal
- Problem Statement: [1-2 sentences describing the user or system problem]
- Business/Technical Outcome: [Observable result when complete]

## In Scope
- [Item 1]

## Out of Scope
- [Item 1]

## Delta Summary
### ADDED
- [module/endpoint/screen]: [Brief description of new capability]

### MODIFIED
- [module/endpoint/screen]: [Exact behavior changing from X to Y]

### REMOVED
- [module/endpoint/screen]: [Deprecated behavior or contract being removed and migration path]
```

## File 2: spec-delta.md (EARS Functional Requirements and Gherkin Scenarios)

```markdown
# Functional Spec Delta: [Short Descriptive Title]

## Formal Requirements (EARS Notation)
- REQ-001 (Ubiquitous): THE SYSTEM SHALL [always-active invariant].
- REQ-002 (Event-Driven): WHEN [trigger event] THE SYSTEM SHALL [system response].
- REQ-003 (State-Driven): WHILE [system state is active] THE SYSTEM SHALL [system response].
- REQ-004 (Unwanted Behavior / Error State): IF [error condition or invalid input] THEN THE SYSTEM SHALL [error handling response matching docs/shared/error-handling.md].

## Error and Empty States
- [Explicit error or empty state behavior]

## Acceptance Criteria
### Scenario 1: [Happy Path Name]
- Given [precondition]
- When [actor action]
- Then [observable outcome and state change]

### Scenario 2: [Boundary or Failure Case Name]
- Given [precondition]
- When [invalid or unauthorized action]
- Then [exact HTTP status, error code, or UI empty/error state]
```

## File 3: design.md (Cross-Layer Technical Plan)

```markdown
# Technical Design Slice: [Short Descriptive Title]

## Architecture Alignment
- Owning Module / Feature Slice: [Path or domain name]
- Affected Layers: [Frontend | Backend | Mobile | Database]
- ADR Compliance: [List relevant ADRs from docs/adr/, or link to the draft ADR created inline]
- Dependency Direction Check: [Confirm compliance with docs/architecture/dependency-rules.md]

## Contract Changes
- **API Contract (specs/api/):** [Endpoints, request/response schemas, status codes]
- **Database Schema (specs/database/):** [Tables, columns, indexes, migration rollback safety]
- **UI States (specs/ui/):** [Loading, empty, error, and success states]
```

## File 4: tasks.md (Atomic Implementation Checklist)

```markdown
# Implementation Tasks: [Short Descriptive Title]

Rules for AI Coding Agents:
1. Execute tasks sequentially in dependency order.
2. Each task must verify tests before marking [x].
3. Do not combine multiple architectural layers in a single unverified step.

## Phase 1: Contracts and Failing Tests
- [ ] T1.1: Update or create schema/contract definitions for [module] (Refs: REQ-001).
- [ ] T1.2: Write failing unit/integration tests covering Scenario 1 and Scenario 2 (Refs: REQ-002).

## Phase 2: Core Implementation
- [ ] T2.1: Implement domain/service logic in [owning module] without violating module boundaries (Refs: REQ-002).
- [ ] T2.2: Wire transport/UI layer and error handling per docs/shared/error-handling.md (Refs: REQ-004).

## Phase 3: Verification and Spec Sync
- [ ] T3.1: Run full test suite and static analysis (docs/shared/static-analysis.md) (Refs: REQ-001).
- [ ] T3.2: Fold spec-delta.md and design.md changes into all affected canonical spec folders (specs/features/, specs/api/, specs/database/, specs/ui/, and specs/acceptance/) (Refs: REQ-001).
```

---

## EARS Quick Reference

| Pattern | Shape | Use when |
|---|---|---|
| Ubiquitous | THE SYSTEM SHALL ... | Always-active invariant, no trigger |
| Event-Driven | WHEN [event] THE SYSTEM SHALL ... | Response to a trigger |
| State-Driven | WHILE [state] THE SYSTEM SHALL ... | Behavior during a mode or state |
| Unwanted Behavior | IF [condition] THEN THE SYSTEM SHALL ... | Errors, invalid input, failures |

Every requirement gets a `REQ-XXX` ID. Every task in `tasks.md`
references at least one `REQ-XXX`. Untraceable requirements are rejected
in review.

---

## Fold-Back Rule

A change is not Merged until its delta is folded into every affected
source-of-truth folder (`features/`, `api/`, `database/`, `ui/`,
`acceptance/`). Fold-back happens in the same pull request as the code.
A merged code change with an unmerged spec delta is spec drift and fails
`spec-verify`.
