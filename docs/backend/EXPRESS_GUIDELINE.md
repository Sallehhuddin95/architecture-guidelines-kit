# Express Backend Architecture and Development Guidelines

This document defines architecture, folder structure, validation boundaries, data access rules, security expectations, and testing standards for a Node.js Express backend.

It is an alternative to the FastAPI and Django backend guidelines. Pick one per project; do not mix multiple backend stacks in the same codebase.

The backend stack is:

- Node.js (current LTS)
- Express (latest stable)
- TypeScript (strict mode)
- PostgreSQL
- Prisma (schema and migrations)
- zod
- Vitest + Supertest

---

## 1. Core Stack

### Runtime and Framework

- Runtime: Node.js LTS
- Framework: Express
- Language: TypeScript (strict mode)
- Package manager: npm
- Data store: PostgreSQL
- Migrations and client: Prisma
- Validation and serialization: zod
- Testing: Vitest + Supertest

---

## 2. Backend Architecture Shape

Use a layered backend structure with clear ownership boundaries.

Preferred structure:

```text
backend/
├── src/
│   ├── routes/          # HTTP entrypoints and route wiring
│   ├── middleware/      # auth, validation, error handling
│   ├── schemas/         # zod request and response contracts
│   ├── services/        # business workflows and rules
│   ├── repositories/    # data access through Prisma
│   └── app.ts           # Express app composition
├── prisma/
│   ├── schema.prisma    # persistence models
│   └── migrations/
└── tests/
```

Rules:

- `routes/` handle HTTP transport only. Handlers validate input, call services, and map responses.
- `schemas/` own request and response validation at the boundary.
- `services/` own business workflows and rules.
- `repositories/` isolate Prisma data access.
- `prisma/schema.prisma` owns persistence structure.
- Do not put business logic or raw Prisma calls in route handlers.

---

## 3. Contracts and Validation

- Use explicit zod schemas for every external input.
- Validate at the boundary: malformed or out-of-contract payloads must fail with a validation error, never silently pass.
- Derive request and response types from schemas with `z.infer`.
- Keep request and response shapes stable and intentional.
- Never trust frontend payload integrity. Reject tampered or unauthorized field changes on the server.
- Follow `docs/shared/api-contract.md` for response shape and error payload consistency.

---

## 4. Authentication and Authorization

- Follow `docs/shared/authentication.md`.
- Default for web apps: server-managed session cookies.
- Use short-lived access tokens with server-side refresh only when the client cannot use sessions (mobile, API-only consumers).
- Enforce authorization on the server in middleware and services. Client-side hiding is not security.

---

## 5. Error Handling

- Follow `docs/shared/error-handling.md`.
- Wrap async handlers so rejected promises reach the error middleware.
- Use one centralized error middleware that maps validation, authentication, authorization, not found, and conflict errors to consistent shapes.
- Log structured diagnostic detail; do not leak internals in public responses.

---

## 6. Data Access and Migrations

- Keep all database access inside repositories.
- Track every schema change through Prisma migrations.
- Keep application code and migration state aligned so deployments stay compatible.
- Do not scatter raw `prisma` calls through services or routes.

---

## 7. Testing

- Unit tests: services and schema validation with Vitest.
- Integration tests: routes through Supertest against a test database.
- Add explicit tests for invalid payloads, auth failures, and protected-field tampering.

---

## 8. Naming Conventions

- Files: `kebab-case.ts`.
- Classes and types: `PascalCase`.
- Functions and variables: `camelCase`.
- Schemas reveal their role: `createInvoiceSchema`, `invoiceResponseSchema`, `listInvoicesParamsSchema`.
- Route files are named by resource: `invoice.routes.ts`, not `routes.ts`.
- Identifiers stay English by default. See `docs/shared/identifier-language.md`.

---

## 9. Review Checklist

- Are route handlers thin and services the owners of business rules?
- Are all external inputs validated by explicit zod schemas at the boundary?
- Is error handling centralized and consistent?
- Are authorization checks enforced on the server?
- Is database access isolated in repositories with migrations tracked?
- Are tests present for invalid payloads, auth failures, and tampering?
- Are identifiers English by default?