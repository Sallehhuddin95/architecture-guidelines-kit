# Guidelines Repository

This repository is a reusable engineering playbook.

It is meant to help you set up or improve another project by giving you:

- repo-wide governance principles
- architecture rules
- frontend and backend guidelines
- shared security and API contract rules
- ADR templates and baseline decisions
- workflow documents
- Copilot custom agents (`.github/agents/`) and opencode agents (`.opencode/agents/`)

It is not an application repo. It is a reference repo for standards, structure, and project governance.

---

## How This Repo Is Organized

This repo is split by purpose.

- `CONSTITUTION.md`: repo-wide purpose, non-negotiable principles, and source-of-truth order
- `docs/architecture/`: system structure, boundaries, and dependency rules
- `docs/frontend/`: frontend implementation standards
- `docs/backend/`: backend implementation standards
- `docs/mobile/`: mobile (React Native/Expo) implementation standards
- `docs/shared/`: cross-stack rules such as auth, API contracts, and error handling
- `docs/adr/`: architecture decision records and ADR guidance
- `docs/workflow/`: how work should move through feature delivery, bug fixing, review, refactoring, and release
- `specs/`: source-of-truth behavior and contract specifications
- `.github/agents/`: Copilot custom agents that enforce or apply the guidance
- `.opencode/`: opencode configuration and custom agents that enforce or apply the same guidance
- `.github/instructions/`: pointer stubs only, not the source of truth; they redirect to `docs/frontend/`, `docs/backend/`, and `docs/mobile/` and are not meant to be copied into target repos

If you plan to use the custom agents, see `.github/agents/README.md` (Copilot) or `.opencode/README.md` (opencode) for when to use each one.

If you are new to this repo, start with `CONSTITUTION.md`, then `docs/architecture/`, then `docs/shared/`, then only the stack-specific folders you actually need.

---

## When to Use This Repo

Use this repo when you want to:

- start a new project with clear rules from day one
- improve an existing repo that has weak structure or inconsistent practices
- standardize architecture, naming, testing, auth, error handling, and review expectations
- give AI agents and contributors a shared source of truth

---

## Fastest Way to Use It

There are two common paths.

### Command Line Install

If this repository is published on GitHub, you can install the selected guideline files into another repository with the PowerShell bootstrap script at the repo root.

From the target project repo, run:

```powershell
irm https://raw.githubusercontent.com/Sallehhuddin95/architecture-guidelines-kit/main/install.ps1 | iex
```

The script will:

1. download and run itself from the guidelines repo
2. ask a few setup questions
3. copy only the matching files into the current project
4. print a summary of what was installed and what to read first

If you prefer not to run a remote script directly, the manual alternative is:

```powershell
$temp = Join-Path $env:TEMP "agk"
git clone --depth 1 https://github.com/Sallehhuddin95/architecture-guidelines-kit.git $temp
powershell -ExecutionPolicy Bypass -File (Join-Path $temp "install.ps1")
Remove-Item -LiteralPath $temp -Recurse -Force
```

### 1. For a New Project

Copy only the docs that match the new project.

Start with these groups:

1. `docs/architecture/`
2. `docs/shared/`
3. `docs/adr/`
4. `specs/README.md`
5. stack-specific docs from `docs/frontend/`, `docs/backend/`, and/or `docs/mobile/`
6. `.github/agents/` and/or `.opencode/` if you use custom agents

Then adapt them immediately to the real stack, real boundaries, and real delivery style of the new repo.

Do not copy everything blindly.

### 2. For an Existing Project

Do not try to force the whole repository into the existing codebase at once.

Instead:

1. copy the architecture and shared rules first
2. add only the frontend or backend docs that the project actually needs
3. write ADRs only for active architectural decisions or important existing decisions worth preserving
4. use the workflow and specs docs only where the team will actually follow them

For an existing project, gradual adoption works better than a big-bang documentation dump.

---

## Recommended Adoption Order

If you want the easiest path, use this order.

### Phase 1: Architecture Baseline

Start here:

- `CONSTITUTION.md`
- `docs/architecture/ARCHITECTURE_GUIDELINE.md`
- `docs/architecture/system-overview.md`
- `docs/architecture/module-boundaries.md`
- `docs/architecture/dependency-rules.md`

These define how the codebase should be shaped.

### Phase 2: Shared Cross-Stack Rules

Then add:

- `docs/shared/authentication.md`
- `docs/shared/api-contract.md`
- `docs/shared/error-handling.md`
- `docs/shared/versioning.md`
- `docs/shared/writing-style.md`
- `docs/shared/identifier-language.md`

These prevent common cross-team and cross-layer inconsistencies.

### Phase 3: Stack-Specific Rules

Add only what your project uses.

Frontend:

- `docs/frontend/FRONTEND_GUIDELINE.md`
- `docs/frontend/naming.md`
- `docs/frontend/testing.md`

Backend:

- `docs/backend/BACKEND_GUIDELINE.md`
- `docs/backend/naming.md`
- `docs/backend/api-design.md`
- `docs/backend/database.md`
- `docs/backend/migrations.md`
- `docs/backend/security.md`
- `docs/backend/testing.md`

Mobile:

- `docs/mobile/MOBILE_GUIDELINE.md`
- `docs/mobile/naming.md`
- `docs/mobile/testing.md`

### Phase 4: ADRs

Use `docs/adr/README.md` to guide decisions.

Keep only the ADRs that are true for the target repo. Rewrite or remove copied ADRs that do not match the new project.

### Phase 5: Specs and Workflow

Use:

- `specs/README.md`
- `docs/workflow/feature-development.md`
- `docs/workflow/bug-fix.md`
- `docs/workflow/refactoring.md`
- `docs/workflow/code-review.md`
- `docs/workflow/release.md`

These help once real delivery work starts.

### Phase 6: Agents

If the target repo uses custom agents, copy `.github/agents/` (Copilot) and/or `.opencode/` (opencode) and make sure the referenced docs also exist in the target repo.

Use `.github/agents/README.md` or `.opencode/README.md` as the quick selector for choosing the right agent per task.

---

## Minimal Copy Guide

### If the New Repo Is Frontend Only

Copy:

- `docs/architecture/`
- `docs/shared/`
- `docs/frontend/`
- `docs/adr/README.md`
- only the ADRs that still apply
- `specs/README.md`
- frontend-relevant agents

### If the New Repo Is Backend Only

Copy:

- `docs/architecture/`
- `docs/shared/`
- `docs/backend/`
- `docs/adr/README.md`
- only the ADRs that still apply
- `specs/README.md`
- backend-relevant agents

### If the New Repo Is Mobile Only

Copy:

- `docs/architecture/`
- `docs/shared/`
- `docs/mobile/`
- `docs/adr/README.md`
- only the ADRs that still apply
- `specs/README.md`
- mobile-relevant agents

### If the New Repo Is Full Stack

Copy:

- `docs/architecture/`
- `docs/shared/`
- `docs/frontend/`
- `docs/backend/`
- `docs/mobile/` (if the project includes a mobile client)
- `docs/adr/`
- `docs/workflow/`
- `specs/README.md`
- `.github/agents/` and `.opencode/`

Then tailor the content before feature delivery begins.

---

## How to Use It Day to Day

Use each part of the repo for a different question.

| Question                                          | Where to Look                                                                      |
| ------------------------------------------------- | ---------------------------------------------------------------------------------- |
| Where should this code live?                      | `docs/architecture/`                                                               |
| What can this module depend on?                   | `docs/architecture/`                                                               |
| How should this feature be structured?            | `docs/frontend/`, `docs/backend/`, or `docs/mobile/`                               |
| How should this be named?                         | `docs/frontend/naming.md`, `docs/backend/naming.md`, or `docs/mobile/naming.md`    |
| How should this be tested?                        | `docs/frontend/testing.md`, `docs/backend/testing.md`, or `docs/mobile/testing.md` |
| How should auth, errors, or contracts work?       | `docs/shared/`                                                                     |
| Does this need a durable architecture decision?   | `docs/adr/`                                                                        |
| How should work move from idea to implementation? | `docs/workflow/` and `specs/README.md`                                             |

---

## Good Practical Rules

- keep only the documents the target repo will actually follow
- update copied docs early so they reflect reality
- do not preserve ADRs that are false for the new project
- do not add specs or workflow files just for ceremony
- use docs during reviews, otherwise they will decay into dead text
- keep agents aligned with the docs they reference

---

## Suggested Day-1 Setup for a New Repo

1. Create the new repo.
2. Copy the minimum relevant folders from this repo.
3. Remove anything that does not match the stack.
4. Rewrite the top architecture and shared rules so they fit the real project.
5. Keep only the ADRs that are already true.
6. Add the stack-specific guidelines.
7. Add agents only if your team will use them.
8. Before building the first real feature, write a short spec.

---

## Suggested Adoption Plan for an Existing Repo

1. Start with architecture and shared rules.
2. Add only the stack-specific guidelines that solve current pain.
3. Record a small number of important ADRs.
4. Use the testing, naming, and review docs during active refactors and feature work.
5. Expand only when the team is actually using the guidance.

---

## Keep It Effective

This repo works well only if the target project treats it as an operating guide.

If documents are copied but never used in planning, implementation, review, or refactoring, they become maintenance noise.

The best use of this repo is:

- copy less
- tailor quickly
- enforce in reviews
- evolve with real project decisions

---

## Start Here

If you want the simplest path:

1. Read `CONSTITUTION.md`.
2. Read `docs/architecture/`.
3. Read `docs/shared/`.
4. Pick either `docs/frontend/`, `docs/backend/`, `docs/mobile/`, or a combination.
5. Use `NEW_PROJECT_BOOTSTRAP.md` if you are creating a fresh repo.
6. Use `EXISTING_PROJECT_ADOPTION.md` if you are improving an existing repo.
7. Use `specs/README.md` before writing the first real feature or API spec.
