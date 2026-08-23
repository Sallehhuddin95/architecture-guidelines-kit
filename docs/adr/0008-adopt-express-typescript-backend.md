# 0008 Adopt Express TypeScript Backend

## Status

Accepted

## Context

Backend guidance in this repository currently covers FastAPI and Django. Node.js with Express is a common third alternative, and projects built on it should follow the same layered, contract-driven governance.

Express needs its own decisions: TypeScript versus plain JavaScript, validation and contract handling at the boundary, persistence access, and a testing stack consistent with the repo's conventions.

## Decision

Add an Express backend guideline as an alternative to the FastAPI and Django guidelines, based on:

- Node.js LTS with Express latest stable
- TypeScript strict mode as the default
- zod for request and response validation at the boundary
- PostgreSQL with Prisma for schema and migrations
- npm for package management
- Vitest + Supertest for testing
- layered structure with thin routes, boundary schemas, service-layer business rules, and repository-isolated data access

One project picks one backend guideline. FastAPI, Django, and Express are not mixed in the same codebase.

## Consequences

Benefits:

- Express projects get explicit layering, contract, and validation rules
- shared auth, API contract, error handling, and naming rules apply unchanged
- agents can enforce a documented Express convention

Costs and tradeoffs:

- the guidelines repo now carries multiple backend stacks, so users must copy only the one they use
- Prisma as the persistence default excludes raw SQL or other ORM preferences unless the project changes it deliberately

## Alternatives Considered

### Plain JavaScript Express

Rejected as the default because TypeScript strict mode keeps contracts explicit and matches the frontend conventions.

### NestJS

Rejected because the goal is a lean Express guideline; NestJS brings its own architecture model that would compete with the repo's layering rules.

### No Express Guidance

Rejected because Node.js projects would drift without documented conventions.