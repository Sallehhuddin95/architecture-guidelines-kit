# Mobile Architecture and Development Guidelines

This document defines architecture, folder structure, navigation strategy, state boundaries, error handling, and testing standards for the React Native mobile app.

All code in this repository must use TypeScript with strict mode enabled.

Prefer the latest stable version of frameworks and libraries when introducing or upgrading dependencies, as long as doing so does not create known compatibility or peer dependency issues in the target project.

Mobile is a separate, dedicated stack. Do not mix mobile-specific code into `docs/frontend/`-governed web projects or vice versa. Shared cross-stack rules still apply from `docs/shared/`.

---

## 1. Core Tech Stack

### Production

- Framework: React Native (Expo, managed workflow)
- Language: TypeScript (strict mode)
- Navigation: Expo Router (file-based routing)
- Data fetching and caching: TanStack Query (v5+)
- Global/local state: Zustand
- Validation: Zod
- Styling: NativeWind (Tailwind-compatible) with Tamagui or gluestack-ui as the component primitive layer
- Secure storage: `expo-secure-store` for tokens and sensitive local data
- Build and distribution: EAS Build, EAS Submit, EAS Update (OTA)

### Dependency Version Policy

- Prefer the latest stable version of major frameworks and libraries when starting a new project or making planned upgrades.
- Do not upgrade blindly when a dependency introduces known compatibility, peer dependency, build, or runtime issues.
- If a project intentionally stays below the latest stable version, document the reason in the relevant repo or upgrade note.

### Testing

- Unit testing: Jest
- Integration testing: Jest + React Native Testing Library (RNTL) + Mock Service Worker (MSW)
- End-to-end testing: Maestro

---

## 2. Design Principles

Apply these principles pragmatically. They are guardrails for maintainable mobile systems, not reasons to over-engineer simple code.

### DRY

- Avoid copy-pasting business logic, query logic, validation rules, and screen behavior across features.
- Do not abstract too early. Duplicate twice if needed, then extract when reuse is real and stable.
- Prefer extracting shared logic into small hooks, services, utilities, or feature-level helper modules.
- Reuse the same TanStack Query, Zustand, and Zod conventions already established for web in `docs/frontend/` where the concept is identical, so one pattern governs one concern across platforms.

### Mobile-Scoped SOLID

- Single responsibility:
  - Screens render UI and compose feature components.
  - Hooks manage reusable stateful behavior.
  - Services perform data access.
  - Schemas validate input.
- Open/closed:
  - Extend behavior through composition, configuration, and small wrappers instead of editing large shared components for every variation.
- Liskov substitution:
  - Variants of shared UI components must preserve expected behavior and prop contracts.
- Interface segregation:
  - Keep props and function signatures narrow; do not pass oversized configuration objects when a smaller contract is enough.
- Dependency inversion:
  - Screens and components should depend on stable service and contract boundaries, not raw fetch or platform API details spread across components.

### Practical Rules

- Prefer composition over inheritance.
- Prefer explicit dependencies over hidden cross-module coupling.
- Keep files small enough that their responsibility is obvious.
- Isolate platform-specific code (`.ios.tsx` / `.android.tsx` variants or `Platform.select`) behind a single shared interface instead of scattering platform checks across features.

---

## 3. Feature-Driven Folder Structure

Use domain and feature-driven architecture. Code for a business capability belongs in its feature folder under `features/`. Global folders are for reusable cross-domain utilities only.

If the Expo SDK version in use supports the `src/` directory convention for Expo Router, place `app/` under `src/app/` for structural consistency with the web frontend. Otherwise, keep `app/` at the project root as required by the Expo Router version in use.

```text
├── app/                           # Expo Router: routes, screens, layouts only
│   ├── _layout.tsx                # Root navigation layout
│   ├── index.tsx                  # Initial route/screen
│   └── dashboard/
│       └── index.tsx              # Route screen that imports feature views
├── src/
│   ├── components/                # Global, domain-agnostic UI
│   │   └── ui/                    # Shared design system primitives
│   ├── features/                  # Business domains
│   │   ├── auth/
│   │   └── dashboard/
│   │       ├── components/        # Feature-scoped components
│   │       ├── hooks/             # Feature-scoped hooks
│   │       ├── services/          # Feature-scoped API clients
│   │       ├── types/             # Feature-scoped types
│   │       └── index.ts           # Feature public API barrel
│   ├── hooks/                     # Global reusable hooks
│   ├── lib/                       # Shared library initialization/config
│   ├── utils/                     # Pure helper functions
│   ├── types/                     # Global, domain-agnostic types
│   └── tests/
│       ├── unit/                  # Unit test suites
│       ├── integration/           # Integration tests with RNTL + MSW
│       └── shared/                # Shared modular fixtures, factories, handlers for unit/integration
├── e2e/
│   ├── fixtures/                  # Maestro-only fixtures/setup helpers
│   ├── factories/                 # Maestro-only data factories/seed helpers
│   └── flows/                     # Maestro E2E flows (*.yaml)
└── assets/                        # Static images, fonts, and icons bundled with the app
```

### Rule of Co-Location

If a component, hook, service, or type is used by only one feature, keep it inside that feature. Move code to global folders only when at least two independent features reuse it.

---

## 4. TypeScript Type and Interface Management

Use the same strict two-tier type model used for web frontend to avoid uncontrolled global type growth.

### Tier 1: Global Types (`/src/types`)

- Purpose: Abstract, data-agnostic structures used across multiple features.
- Examples: API envelopes, paginated responses, common list states, metadata contracts.

### Tier 2: Feature Types (`/src/features/[feature-name]/types`)

- Purpose: Business-domain models local to one feature.
- Examples: User entities, feature payloads, form contracts.

### Safeguards

- Isolated imports: Do not directly import one feature's types into another feature.
- Hoist only when needed: If a type becomes broadly shared, move it to `/src/types/common.ts` (or another explicit shared location).
- Token choice:
  - Prefer `interface` for extendable object contracts.
  - Prefer `type` for unions, intersections, primitive aliases, and tuples.

---

## 5. Navigation and Data Flow

- Use Expo Router for file-based navigation, mirroring the route-first mental model already used by the Next.js App Router on web.
- Keep `app/` focused on routing, layout composition, and screen wiring only; delegate business behavior to `features/`.
- Use TanStack Query `useQuery` and `useMutation` for all server-state fetching and caching.
- Prefetch data ahead of navigation only when the UX benefit is clear (for example, prefetching a detail screen from a list item press).
- Avoid duplicate fetching for the same data across sibling screens; rely on the shared query cache.

---

## 6. Unified Error Handling Architecture

Use a layered error model to preserve UX resilience on mobile.

### Layer 1: Screen and Navigation Boundaries

- Wrap top-level navigators and risky screens with React error boundaries.
- Keep unaffected screens functional; provide retry or navigate-back actions.
- Show fallback UI that explains what failed in user language and gives a safe next action.

### Layer 2: Async and Network Errors (TanStack Query)

- Configure global handling through centralized `QueryCache` and `MutationCache` callbacks.
- Surface failures via non-blocking UI feedback (toast/banner) rather than blocking the whole screen.
- Distinguish offline/no-connectivity states from generic server failures; offer retry when connectivity returns.
- Never expose raw stack traces, internal error codes, or backend exception text directly to end users.

### Layer 3: Form and Input Validation

- Validate inputs with Zod schemas shared conceptually with the web contract validation approach.
- Catch parse and validation failures in the local form layer before network submission.
- Map validation errors to the exact field that needs correction.

---

## 7. State Management Boundaries

Separate state into clear ownership zones, matching the web frontend model:

- Server state:
  - Managed by TanStack Query.
  - Do not duplicate server state into local component state unless strictly required.
- UI state:
  - Local interaction state (accordion open state, form draft mode, toggle switches).
  - Managed with React `useState` or `useReducer`.
- Global UI state:
  - Thin cross-app concerns (navigation state helpers, theme mode, onboarding flags).
  - Managed in isolated Zustand stores.

---

## 8. Performance and Loading Strategy

- Use `FlashList` (or an equivalent virtualization library) for large or long lists instead of plain `ScrollView`/`FlatList` mapping.
- Use `expo-image` (or an equivalent optimized image component) with explicit sizing and caching behavior.
- Avoid unnecessary re-renders by keeping component trees shallow and memoizing only when profiling shows a real cost.
- Lazy-load heavy, rarely used screens or third-party widgets where the navigation library supports it.
- Keep loading, retry, and background refresh states localized to the affected screen or section.

---

## 9. Authentication and Authorization

Mobile clients cannot rely on browser cookies. Treat authentication as a server-backed security concern first, and a UI/navigation concern second.

### Token Handling

- Store access and refresh tokens using `expo-secure-store` (or platform keychain/keystore equivalents). Never use unencrypted storage such as `AsyncStorage` for tokens.
- Use short-lived access tokens with a refresh flow coordinated through the backend session/auth service defined in `docs/shared/authentication.md`.
- Do not log tokens or embed them in crash reports or analytics events.

### OAuth and Deep Linking

- Use OAuth 2.0 with OpenID Connect via in-app browser flows (for example Expo `AuthSession`) when third-party login or SSO is required.
- Handle the OAuth redirect through a registered deep link/universal link, then exchange the result for a securely stored session token set.

### Authorization Rules

- Perform authorization checks on the server whenever possible, exactly as required by `docs/shared/authentication.md`.
- Treat client-side navigation guards as UX assistance, not the primary security boundary.
- Design unauthenticated, unauthorized, expired-session, and forbidden states as explicit navigation flows (for example, redirecting to a sign-in screen).

---

## 10. Testing Support Boundaries

Use modular testing support with clear ownership by test layer.

- `src/tests/shared/` is the shared support surface for unit and integration tests.
- Put reusable Jest/RNTL fixtures in `src/tests/shared/fixtures/`.
- Put reusable deterministic data builders in `src/tests/shared/factories/`.
- Put shared MSW handlers and related network test support in `src/tests/shared/handlers/`.
- Keep Maestro support separate under `e2e/fixtures/` and `e2e/factories/`.
- Do not mix Jest/RNTL shared support with Maestro support.

---

## 11. Review Checklist

- Does application code live under `src/` (or `src/app/` when supported) with routes kept thin?
- Are TanStack Query, Zustand, and Zod used consistently with the web frontend conventions?
- Are tokens stored only in secure storage, never in unencrypted local storage?
- Are authorization decisions enforced on the server, not only hidden in the UI?
- Do unit/integration tests share `src/tests/shared/` while Maestro keeps its own `e2e/` fixtures and factories?
- Does this change require an ADR, spec, or shared doc update?

---

## Dedicated Guides

For mobile-specific detail, refer to:

- `naming.md`: naming, casing, and mobile-specific symbol conventions.
- `testing.md`: Jest/RNTL setup patterns, MSW examples, and Maestro practices.
