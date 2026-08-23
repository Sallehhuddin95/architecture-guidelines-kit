# Django Backend Architecture and Development Guidelines

This document defines architecture, folder structure, validation boundaries, data access rules, security expectations, and testing standards for a Django backend.

It is an alternative to the FastAPI backend guideline. Pick one per project; do not mix both in the same codebase.

The backend stack is:

- Django (latest stable)
- Django REST Framework (DRF) as the primary API layer
- PostgreSQL
- Django migrations
- uv
- pytest + pytest-django

---

## 1. Core Stack

### Runtime and Framework

- Framework: Django
- API layer: Django REST Framework. Django Ninja is an acceptable alternative when a project wants Pydantic-style contracts, but do not use both in the same project.
- Python package and environment management: uv
- Data store: PostgreSQL
- Migrations: Django migrations
- Validation and serialization: DRF serializers
- Testing: pytest + pytest-django

---

## 2. Backend Architecture Shape

Use a layered backend structure with clear ownership boundaries.

Preferred structure:

```text
backend/
├── config/            # settings, root urls, wsgi/asgi
├── apps/              # Django apps by business capability
│   ├── accounts/      # auth and user profiles
│   ├── billing/       # invoices and payments
│   └── reports/       # reporting capability
└── manage.py
```

Each app follows the same internal layering:

```text
apps/billing/
├── urls.py            # route wiring only
├── views.py           # thin HTTP entrypoints
├── serializers.py     # request and response contracts
├── services.py        # business workflows and rules
├── models.py          # persistence structures
├── permissions.py     # app-scoped authorization rules
├── migrations/
├── tests/
└── factories.py       # test factories
```

Rules:

- `views.py` handles HTTP transport only. It maps requests to services and serializes responses.
- `serializers.py` owns validation and contract mapping at the boundary.
- `services.py` owns business workflows and rules.
- `models.py` owns persistence structure. Keep heavy business logic out of models.
- Do not put business logic in `views.py` or `models.py`.

---

## 3. Contracts and Validation

- Use explicit DRF serializers for every external input and output.
- Validate input at the boundary: malformed or out-of-contract payloads must fail with a validation error, never silently pass.
- Keep request and response shapes stable and intentional.
- Never trust frontend payload integrity. Reject tampered or unauthorized field changes on the server.
- Follow `docs/shared/api-contract.md` for response shape and error payload consistency.

---

## 4. Authentication and Authorization

- Follow `docs/shared/authentication.md`.
- Default for web apps: server-managed session authentication with DRF `SessionAuthentication`.
- Use token or JWT authentication only when the product needs it (mobile clients, API-only consumers), and keep token handling server-side.
- Enforce authorization on the server with DRF permission classes and service-level ownership checks. Client-side hiding is not security.

---

## 5. Data Access and Migrations

- Track every schema change through Django migrations.
- Keep application code and migration state aligned so deployments stay compatible.
- Use `select_related` / `prefetch_related` deliberately to avoid N+1 queries.
- Keep database access scoped to the app that owns the model.

---

## 6. Error Handling

- Follow `docs/shared/error-handling.md`.
- Use DRF's structured exception responses and map validation, authentication, authorization, not found, and conflict errors to distinct, consistent shapes.
- Log structured diagnostic detail; do not leak internals in public responses.

---

## 7. Testing

- Use pytest + pytest-django.
- Unit tests: services, permissions, and serializers.
- Integration tests: API endpoints through `APIClient` against a test database.
- Add explicit tests for invalid payloads, auth failures, and protected-field tampering.
- Use `factory_boy` factories instead of hand-built fixtures where practical.

---

## 8. Naming Conventions

- Apps: plural `snake_case` by capability (`accounts`, `billing`).
- Python files: `snake_case.py`.
- Classes: `PascalCase`.
- Functions and variables: `snake_case`.
- Serializers reveal their role: `InvoiceCreateSerializer`, `InvoiceResponseSerializer`, not generic `InvoiceSerializer` when the role can be made explicit.
- Identifiers stay English by default. See `docs/shared/identifier-language.md`.

---

## 9. Review Checklist

- Is `views.py` thin and `services.py` the owner of business rules?
- Are all external inputs validated by explicit serializers at the boundary?
- Are authorization checks enforced on the server?
- Are schema changes tracked by migrations?
- Are error responses consistent and internal-safe?
- Are tests present for invalid payloads, auth failures, and tampering?
- Are identifiers English by default?