---
applyTo: "**/frontend/**,**/web/**,**/client/**,**/*.component.ts,**/*.component.html,**/next.config.*,**/angular.json"
description: "Frontend feature-driven architecture, state, UI, Next.js BFF routes, and testing rules"
---

# Frontend Instructions (Pointer)

Note: Next.js `app/api/**` BFF route handlers are owned by the frontend
workspace boundary. They must still enforce shared transport and security
rules from `docs/shared/api-contract.md`, `docs/shared/error-handling.md`,
and ADR-0004.

This file is not the source of truth.

The canonical frontend architecture and development guidelines live at:

- [`docs/frontend/FRONTEND_GUIDELINE.md`](../../docs/frontend/FRONTEND_GUIDELINE.md) (Next.js)
- [`docs/frontend/ANGULAR_GUIDELINE.md`](../../docs/frontend/ANGULAR_GUIDELINE.md) (Angular standalone)

Related canonical frontend docs:

- [`docs/frontend/naming.md`](../../docs/frontend/naming.md)
- [`docs/frontend/testing.md`](../../docs/frontend/testing.md)

Do not duplicate frontend guidance into this file. Update the canonical docs above instead, and keep any agent references pointed at `docs/frontend/`.
