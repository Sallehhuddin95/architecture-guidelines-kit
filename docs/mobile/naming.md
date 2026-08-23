# Mobile Naming Conventions

This document defines naming rules specific to the React Native (Expo) mobile app.

For TypeScript type/interface naming, variable and function naming, constant naming, service naming, TanStack Query key naming, and Zod schema naming, follow `docs/frontend/naming.md` exactly — these conventions are shared across web and mobile so one pattern governs one concern. This document only defines the rules that differ for mobile.

---

## 1. Naming Principles

- Prefer explicit, domain-meaningful names over short or generic names.
- Keep naming consistent with the equivalent web frontend concept when the concept is shared (services, hooks, schemas, query keys).
- Use suffixes only when they clarify intent, not as noise.
- Code identifiers must be English by default, even when the app UI is in another language. See `docs/shared/identifier-language.md`.

---

## 2. Directory and File Casing Matrix

| Element                              | Rule                                  | Example                                            |
| ------------------------------------ | ------------------------------------- | -------------------------------------------------- |
| Expo Router route folders in `app/`  | `kebab-case` lowercase                | `app/billing-history/`                             |
| Route group folders                  | Parentheses + `kebab-case`            | `app/(auth)/`                                      |
| Dynamic segments                     | Bracket syntax                        | `app/posts/[postId].tsx`                           |
| Catch-all segments                   | Bracket ellipsis syntax               | `app/docs/[...slug].tsx`                           |
| Feature folders                      | `kebab-case` lowercase                | `features/user-profile/`                           |
| Component files                      | `PascalCase.tsx`                      | `RevenueChart.tsx`                                 |
| Platform-specific component variants | `PascalCase.ios.tsx` / `.android.tsx` | `RevenueChart.ios.tsx`, `RevenueChart.android.tsx` |
| Hook files                           | `camelCase` with `use` prefix         | `useDashboardMetrics.ts`                           |
| Service files                        | `kebab-case` with verb/noun intent    | `get-dashboard-metrics.ts`, `create-session.ts`    |
| Utility files                        | `kebab-case`                          | `format-currency.ts`, `build-query-string.ts`      |
| Type files                           | `kebab-case`                          | `analytics.ts`, `auth-session.ts`                  |
| Test files (unit/integration)        | `*.test.ts(x)`                        | `revenue-chart.test.tsx`                           |
| Maestro E2E flows                    | `*.flow.yaml`                         | `checkout-flow.flow.yaml`                          |

Notes:

- Do not use `index.tsx` for main feature components; use explicit names.
- `index.ts` is allowed only as a feature public API barrel.
- Reserve platform-specific file suffixes (`.ios.` / `.android.`) for real platform divergence, not as a default pattern.

---

## 3. Expo Router Reserved Files

Always keep reserved Expo Router filenames lowercase and exact:

- `_layout.tsx`
- `index.tsx`
- `+not-found.tsx`

Use default exports only where Expo Router requires them (route files under `app/`).

---

## 4. Screen and Navigation Naming

- Screen component names should match their route intent: `DashboardScreen`, `LoginScreen`, `ProfileScreen`.
- Navigation param types should be named `{ScreenName}Params` and colocated with the route or feature that owns the screen.
- Deep link and universal link route names should match the corresponding `app/` route path.

```ts
export interface DashboardScreenParams {
  dashboardId: string;
}
```

---

## 5. Import and Alias Conventions

- Use path alias imports (for example `@/features/...`) where configured via `babel.config.js` module resolver or `tsconfig.json` paths.
- Order imports consistently:
  1. external packages
  2. internal aliases
  3. relative imports
- Avoid deep cross-feature relative imports.
- Do not import from another feature's private internals; consume feature public API when exposed.

---

## 6. Test Naming Conventions

- Test title describes behavior, not implementation details.
- Use `should` style or plain behavior style consistently, matching `docs/frontend/naming.md`.
- Maestro flow files should be named after the user journey they validate, not the screen alone.

Examples:

- `renders empty state when no metrics exist`
- `should submit form when input is valid`
- `redirects unauthenticated user to sign-in`
- `checkout-flow.flow.yaml`

---

## 7. Review Checklist

- Are route and feature folders in `kebab-case`?
- Are platform-specific file variants used only for real platform divergence?
- Are screen components and navigation param types named consistently?
- Are service, query key, and schema names aligned with `docs/frontend/naming.md` conventions?
- Are imports respecting feature boundaries and alias conventions?
- Are Maestro flow files named after the user journey they validate?
