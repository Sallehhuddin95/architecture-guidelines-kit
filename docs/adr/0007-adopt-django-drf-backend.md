# 0007 Adopt Django with DRF Backend

## Status

Accepted

## Context

Backend guidance in this repository currently covers FastAPI only. Django is a widely used alternative, and projects built on it should follow the same layered, contract-driven governance instead of ad hoc conventions.

Django needs its own decisions: which API layer to default to, where business logic lives relative to Django views and models, and how contracts and validation behave at the boundary.

## Decision

Add a Django backend guideline as an alternative to the FastAPI guideline, based on:

- Django latest stable
- Django REST Framework (DRF) as the primary API layer
- Django Ninja noted as an acceptable alternative for projects that prefer Pydantic-style contracts, but never both in the same project
- PostgreSQL with Django migrations
- uv for environment management
- pytest + pytest-django for testing
- layered apps by capability with thin views, boundary serializers, service-layer business rules, and persistence-only models

One project picks one backend guideline. FastAPI, Django, and Express are not mixed in the same codebase.

## Consequences

Benefits:

- Django projects get explicit layering, contract, and validation rules
- shared auth, API contract, error handling, and naming rules apply unchanged
- agents can enforce a documented Django convention

Costs and tradeoffs:

- the guidelines repo now carries multiple backend stacks, so users must copy only the one they use
- DRF-first guidance means Ninja-style projects must consciously choose the alternative

## Alternatives Considered

### Django Ninja as Primary

Rejected as the primary because DRF is the more widely known and established Django API layer, and its serializer model maps cleanly to the contract-at-the-boundary rule. Ninja stays documented as an option.

### Fat Django Views and Models

Rejected because business logic in views or models collapses the layering that the backend governance requires.

### No Django Guidance

Rejected because Django projects would drift without documented conventions.