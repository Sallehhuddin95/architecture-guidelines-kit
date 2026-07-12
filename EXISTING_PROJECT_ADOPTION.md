# Existing Project Adoption Guide

Use this guide when you want to apply this repository to a project that already exists.

The goal is not to force a perfect documentation set all at once. The goal is to improve structure, consistency, and delivery quality without disrupting active work unnecessarily.

---

## 1. Start With the Current Pain

Before copying any files, identify the actual problems in the existing repo.

Typical examples:

- code placement is inconsistent
- dependency boundaries are unclear
- API contracts drift between frontend and backend
- authentication or authorization behavior is weak or inconsistent
- naming rules vary by feature or developer
- tests are shallow or uneven
- reviews are inconsistent because there is no shared standard

Do not adopt this repository as a full package unless the current project genuinely needs it.

---

## 2. Adopt in Phases

For an existing repo, use gradual adoption.

Recommended order:

1. architecture rules
2. shared cross-stack rules
3. the stack-specific docs that address active problems
4. ADRs for important current decisions
5. specs and workflow docs only when the team is ready to use them
6. agents only if the repo uses Copilot custom agents in practice

This keeps the change set manageable and prevents documentation from getting ahead of team behavior.

---

## 3. Phase 1: Add the Architecture Baseline

Start with:

- `docs/architecture/ARCHITECTURE_GUIDELINE.md`
- `docs/architecture/system-overview.md`
- `docs/architecture/module-boundaries.md`
- `docs/architecture/dependency-rules.md`

Use these to clarify:

- what belongs where
- what may depend on what
- where shared code should and should not live
- whether the current structure needs incremental cleanup

For an existing repo, these documents are the best first lever because they improve decisions without requiring a full rewrite.

---

## 4. Phase 2: Add Shared Rules

Then adopt:

- `docs/shared/authentication.md`
- `docs/shared/api-contract.md`
- `docs/shared/error-handling.md`

These help stabilize the rules that usually drift the most in mature repos:

- auth responsibilities
- request and response expectations
- error behavior
- trust boundaries between client and server

If your project already has production traffic, these rules usually provide immediate review value.

---

## 5. Phase 3: Add Only the Stack-Specific Guidance You Need

Do not copy frontend and backend guidance just because both folders exist here.

Choose based on the actual repo:

- `docs/frontend/` if the project has frontend structure, naming, and testing issues
- `docs/backend/` if the project has backend layering, contract, security, migration, or testing issues

Prioritize the docs that solve current pain, not theoretical future pain.

---

## 6. Record Only Important ADRs

In an existing repo, ADRs should capture decisions that are either:

- already true and worth preserving
- newly chosen and likely to shape future work
- contentious enough that contributors may otherwise reverse them later

Good examples:

- adopting feature-driven frontend structure
- adopting layered FastAPI boundaries
- choosing server-managed sessions
- rejecting client tampering of protected fields

Do not backfill ADRs for trivial historical choices.

---

## 7. Use Specs Only for Real Delivery Work

If the current repo does not already use specs, do not introduce full specs for every old feature.

Instead:

1. start specs on the next meaningful feature or API change
2. use them where behavior, contract, or acceptance clarity matters
3. avoid retro-documenting the full product unless there is a clear business reason

This keeps specs useful rather than overwhelming.

---

## 8. Introduce Rules Through Active Work

The most effective adoption pattern is to apply the guidance while shipping real work.

Good entry points:

- an active feature
- a bug fix in a fragile area
- a refactor of a messy module
- a security-sensitive endpoint change
- a contract cleanup between frontend and backend

This lets the team test whether the guidance is practical before expanding it.

---

## 9. Use Reviews to Enforce the Guidance

Documentation will not help unless it changes review behavior.

Once the docs are copied into the target repo, use them in pull requests to ask:

- is this code in the right place?
- does it follow the intended dependency direction?
- is the contract explicit?
- are auth and trust-boundary rules enforced on the server?
- are naming and testing aligned with the guidance?
- does this change need an ADR or spec update?

If the team does not review against the guidance, the documents will decay quickly.

---

## 10. Add Agents Only If They Match Real Team Usage

If the project uses Copilot custom agents, copy the relevant files from `.github/agents/`.

Before doing that, confirm:

- the referenced docs exist in the target repo
- the agent matches the actual stack
- the team wants agent-guided implementation or review

If those conditions are not true, skip the agents for now.

---

## 11. Good Minimal Rollout

If you want the lightest useful adoption plan for an existing repo, do this:

1. copy `docs/architecture/`
2. copy `docs/shared/`
3. copy only one stack-specific folder if needed
4. add `docs/adr/README.md`
5. record only one or two important ADRs
6. use the docs in active reviews for two weeks
7. expand only if the team is actually using them

That is usually enough to improve an existing codebase without creating documentation overload.

---

## 12. First Review After Adoption

After the first one to two weeks, evaluate:

- which docs were actually referenced
- which rules were unclear or too strict
- whether the team followed the naming and testing guidance
- whether specs felt useful or heavy
- whether another ADR is needed
- whether any copied files should be removed

Adoption quality matters more than document count.
