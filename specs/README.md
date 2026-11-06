# Specifications

This folder contains the source-of-truth specifications for planned and implemented behavior.

Specs exist to align architecture, implementation, testing, and review before code drifts into undocumented behavior.

---

## Two-Tier Model

This folder uses two tiers. Do not mix them.

### 1. Source-of-Truth Specs

`features/`, `api/`, `database/`, `ui/`, `acceptance/`

These represent the current, approved behavior of the system in production.
Read them to learn what the system does today. Change them only through
a merged change bundle (tier 2), never by direct ad-hoc edits alongside code.

### 2. Active Change Proposals

`changes/<YYYY-MM-DD-change-slug>/`

These represent in-flight feature additions, modifications, or removals
before and during implementation. Each change directory holds a four-file
bundle: `proposal.md`, `spec-delta.md`, `design.md`, `tasks.md`
(see `changes/README.md`).

Once a change is implemented, verified, and merged, its delta is folded
into all affected source-of-truth folders and the change directory is
archived or marked Merged.

---

## Change Lifecycle

Every change bundle moves through these states in order:

- Draft -> Proposed (human review gate) -> Planned (architecture and task breakdown verified) -> In Progress -> Verified (all acceptance criteria and boundary checks pass) -> Merged (folded into source-of-truth specs)

Rules:

- Nothing leaves Draft without scope boundaries (`## In Scope` / `## Out of Scope`).
- Nothing leaves Proposed without human approval.
- Nothing leaves Planned without a verified design and task breakdown.
- Nothing is Merged until `spec-verify` passes and the fold-back into
  source-of-truth specs is complete.

---

## Start Here

Use this folder when a change needs clear behavior definition before implementation.

Start with this rule of thumb:

- if the work changes product behavior, write or update a spec
- if the work changes architecture or a durable technical decision, write or update an ADR instead

Suggested first step:

1. Create a change bundle in `changes/<YYYY-MM-DD-slug>/` (see `changes/README.md`).
2. Add related API, UI, database, or acceptance deltas only if the change needs them.
3. Keep the change narrow and tied to one bounded concern.

---

## Structure

- `features/`: feature-level behavior and scope (current production truth)
- `api/`: transport and endpoint contracts (current production truth)
- `database/`: schema and persistence-oriented design notes (current production truth)
- `ui/`: user interface behavior and screen-level expectations (current production truth)
- `acceptance/`: user-visible acceptance criteria and scenario definitions (current production truth)
- `changes/`: in-flight change bundles with ADDED / MODIFIED / REMOVED deltas

---

## Usage Rules

- Write or update specs before or alongside meaningful behavior changes.
- Keep specs concrete enough to guide implementation and testing.
- Prefer one change bundle per bounded concern instead of one giant catch-all document.
- Fold merged deltas into source-of-truth specs in the same pull request as the code.
- If a change is architectural rather than feature-specific, document it in `docs/adr/` instead.

---

## Recommended Flow

1. Propose the change (`proposal.md` + `spec-delta.md`).
2. Plan the architecture slice (`design.md`).
3. Break down test-first tasks (`tasks.md`).
4. Implement against the change bundle.
5. Validate tests and behavior against the documented expectations.
6. Fold the delta into source-of-truth specs and mark the bundle Merged.
