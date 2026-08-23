# 0006 Adopt Angular Standalone Frontend

## Status

Accepted

## Context

Frontend guidance in this repository currently covers Next.js App Router only. Some projects legitimately use Angular, and contributors should get the same governance quality there instead of inventing conventions on the fly.

Angular needs its own decisions: standalone components versus NgModules, server state handling, and a testing stack that matches the repo's existing frontend conventions.

## Decision

Add an Angular frontend guideline as an alternative to the Next.js guideline, based on:

- Angular latest stable with standalone components as the default (no NgModules unless a documented legacy reason exists)
- TypeScript strict mode
- TanStack Query (Angular adapter) for server state
- Angular signals for local UI state
- feature-driven folder structure matching the frontend architecture rules
- Vitest + Angular Testing Library for unit and integration tests, Playwright for e2e

One project picks one frontend guideline. Next.js and Angular are not mixed in the same codebase.

## Consequences

Benefits:

- Angular projects get explicit structure, state, and testing rules instead of ad hoc choices
- shared architecture, auth, error, contract, and naming rules apply unchanged
- agents can enforce a documented Angular convention

Costs and tradeoffs:

- the guidelines repo now carries two frontend stacks, so users must copy only the one they use
- standalone-only guidance excludes NgModule-style codebases unless they opt in

## Alternatives Considered

### NgModule-Based Angular

Rejected as the default because standalone components are the current Angular default, simpler, and better suited to feature-driven structure.

### Karma + Jasmine

Rejected as the default test runner because Vitest keeps the frontend testing story consistent with the Next.js guideline.

### No Angular Guidance

Rejected because projects using Angular would drift without documented conventions.