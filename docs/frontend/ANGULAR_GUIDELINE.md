# Angular Architecture and Development Guidelines

This document defines architecture, folder structure, state boundaries, error handling, and testing standards for an Angular project.

It is an alternative to the Next.js frontend guideline. Pick one per project; do not mix both in the same codebase.

All code in this repository must use TypeScript with strict mode enabled.

Prefer the latest stable version of frameworks and libraries when introducing or upgrading dependencies, as long as doing so does not create known compatibility or peer dependency issues in the target project.

---

## 1. Core Tech Stack

### Production

- Framework: Angular (latest stable, standalone components)
- Language: TypeScript (strict mode)
- Server state: TanStack Query (Angular adapter)
- Local state: Angular signals
- Styling: Tailwind CSS; use Angular Material only when a ready-made component set is required
- Forms and validation: reactive forms + Zod schemas

### Dependency Version Policy

- Prefer the latest stable version of major frameworks and libraries when starting a new project or making planned upgrades.
- Do not upgrade blindly when a dependency introduces known compatibility, peer dependency, build, or runtime issues.
- If a project intentionally stays below the latest stable version, document the reason in the relevant repo or upgrade note.

### Testing

- Unit testing: Vitest
- Integration testing: Vitest + Angular Testing Library + MSW
- End-to-end testing: Playwright

---

## 2. Design Principles

Apply these principles pragmatically. They are guardrails, not reasons to over-engineer simple code.

- DRY: avoid copy-pasting business logic, query logic, validation rules, and UI behavior across features.
- Prefer composition over inheritance.
- Keep components, services, and schemas focused on one responsibility.
- Depend on stable service and contract boundaries instead of spreading fetch and parsing logic through components.
- Keep component inputs, outputs, and service signatures narrow.
- Apply abstraction only after clear repeated use.

---

## 3. Architecture Shape

Use a feature-driven structure with clear ownership boundaries.

Preferred structure:

```text
src/
├── app/                 # routing and top-level composition
│   ├── app.routes.ts
│   └── app.config.ts
├── features/            # business capabilities
│   └── invoices/
│       ├── pages/       # route components (standalone)
│       ├── components/  # feature-scoped UI
│       ├── services/    # feature services and TanStack Query hooks
│       ├── schemas/     # Zod contracts and forms
│       └── types/       # feature types
└── shared/              # domain-agnostic primitives
    ├── ui/              # generic components
    ├── utils/
    └── types/
```

Rules:

- `app/` may define routes, layouts, and lazy loading only. It must not hold feature business logic.
- Feature modules own business-facing UI, services, schemas, and types.
- `shared/` stays domain-agnostic. Promote code into it only when multiple independent features reuse it.
- Use standalone components by default. Do not create `NgModule` modules unless the project has a documented legacy reason.
- Lazy-load feature routes with `loadComponent`.

---

## 4. Data and State Strategy

- Server state: TanStack Query for fetching, caching, retries, and mutations.
- Local UI state: signals or `signal`-based stores for component-local concerns.
- Never mirror server state into local state without a clear reason.
- Keep network code in feature services, not in components.
- Use `inject()` and functional guards instead of constructor injection.

---

## 5. Authentication and Authorization

- Follow `docs/shared/authentication.md`.
- Route guards are UX assistance, not the security boundary. The server enforces authorization.
- Keep auth state as display state: sign-in state, session expiration, and forbidden states render explicit UI.

---

## 6. Error Handling

- Follow `docs/shared/error-handling.md`.
- Use TanStack Query error states for recoverable request failures: explicit loading, empty, error, and retry UI.
- Use `ErrorHandler` for global unexpected errors and route-level fallbacks for crashed route slices.
- Do not leak raw exception details to users.

---

## 7. Naming Conventions

- Files: `kebab-case` (`invoices-page.component.ts`, `invoice.service.ts`, `invoice.schema.ts`).
- Classes and types: `PascalCase`.
- Functions, properties, and signals: `camelCase`.
- Components: `PascalCase` with `Component` suffix; route components use a `Page` suffix where useful.
- Services: `InvoiceService`, not `InvoiceHelper` or `InvoiceManager`.
- Identifiers stay English by default. See `docs/shared/identifier-language.md`.

---

## 8. Testing

- Unit tests: pure logic, services, and schemas with Vitest.
- Integration tests: standalone components with Angular Testing Library and MSW for server state.
- E2E tests: Playwright for user journeys and route-level behavior.
- Test names describe behavior, not implementation.

---

## 9. Review Checklist

- Are feature boundaries respected (`app` / `features` / `shared`)?
- Are standalone components used by default?
- Is server state managed by TanStack Query, not duplicated in local state?
- Are guards treated as UX only, with server-side enforcement?
- Are error and loading states explicit?
- Do names follow `kebab-case` files and `PascalCase`/`camelCase` classes and members?
- Are identifiers English by default?