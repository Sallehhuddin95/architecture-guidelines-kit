# Feature Development Workflow

This document defines the default workflow for implementing a new feature.

The goal is to make feature work consistent, reviewable, and aligned with architecture and specs.

---

## 1. Start Conditions

Before implementation begins, the feature should have:

- a clear problem statement
- defined scope boundaries
- acceptance criteria
- identified affected layers
- known architecture or contract constraints

If those are missing, define them before coding.

---

## 2. Recommended Workflow

1. Confirm the feature goal and out-of-scope items.
2. Identify which feature module or system area owns the change.
3. Review relevant docs:
   - architecture guidance
   - frontend, backend, or mobile rules
   - shared auth, error, or API rules
   - relevant ADRs and specs
4. Update or create the feature spec if behavior is not already documented.
5. Design the change at the smallest architecture-consistent slice.
6. Write or update tests for the intended behavior where practical.
7. Implement the feature.
8. Validate behavior, tests, and architecture boundaries.
9. Update docs if the feature changes contracts, flows, or conventions.

### Slash Command Mapping

Each command below executes the numbered steps above and stops at its
gate. Commands run in order; a later command refuses to run if the
earlier gate is not satisfied.

- `/spec.propose` executes Steps 1-4. Produces `proposal.md` and
  `spec-delta.md` in `specs/changes/<YYYY-MM-DD-slug>/`. Hard stop:
  no code, no implementation plan. Human reviews and approves first.
- `/spec.plan` executes Step 5. Produces `design.md` with exact file
  paths, boundaries, contracts, and migrations. Drafts a `Proposed` ADR
  inline if the change departs from existing rules. Hard stop: no code.
- `/spec.tasks` bridges Steps 5-6. Produces `tasks.md`: test-first atomic
  tasks each mapped to at least one `REQ-XXX`.
- `/spec.verify` executes Steps 8-9. Compares the diff against the bundle,
  audits boundaries and ADR-0004, checks test coverage per requirement,
  emits a pass/fail Verification Report, and folds the delta into
  canonical `specs/` on full pass.

---

## 3. Implementation Rules

- Respect ownership boundaries.
- Prefer extending existing patterns over inventing new ones.
- Avoid mixing multiple unrelated concerns in one change set.
- Use the smallest sufficient layer for validation.
- If the feature introduces a structural or cross-cutting change, consider an ADR.

---

## 4. Testing Expectations

- Add unit tests for isolated logic.
- Add integration tests for interactive or async UI behavior.
- Add end-to-end coverage for critical route or user journey changes.
- Prefer behavior-focused tests over implementation-coupled tests.

---

## 5. Completion Checklist

- Is the feature scope clear and still controlled?
- Does the implementation respect module boundaries?
- Are tests added or updated at the correct level?
- Are shared contracts still valid?
- Does the change require doc, spec, or ADR updates?
