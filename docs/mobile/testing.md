# Mobile Testing Guidelines and Architecture

This document defines the project testing strategy for the React Native (Expo) mobile app using Jest, React Native Testing Library (RNTL), Mock Service Worker (MSW), and Maestro.

For core testing philosophy (AAA structure, red-green-refactor, flake prevention, layer selection) follow `docs/frontend/testing.md` — the same principles apply on mobile. This document defines the mobile-specific tooling, directory contract, and examples.

---

## 1. Testing Layers

| Layer       | Purpose                                                      | Tools             | Directory                | Must Not Depend On                                       |
| ----------- | ------------------------------------------------------------ | ----------------- | ------------------------ | -------------------------------------------------------- |
| Unit        | Pure logic, utilities, data transforms                       | Jest              | `src/tests/unit/`        | Native rendering, network, real timers, global providers |
| Integration | Screen/component behavior, async UI, query/cache interaction | Jest + RNTL + MSW | `src/tests/integration/` | Real backend services                                    |
| E2E         | Full device/simulator workflows and navigation flows         | Maestro           | `e2e/flows/`             | Internal implementation details                          |

---

## 2. Directory Contract

Testing structure must follow:

```text
src/tests/
  unit/
  integration/
  shared/
    fixtures/
    factories/
    handlers/
e2e/
  fixtures/
  factories/
  flows/
```

Rules:

- Unit and integration tests must share modular fixtures and factories from `src/tests/shared/`.
- Organize shared test support into small focused modules under `src/tests/shared/fixtures/` and `src/tests/shared/factories/` instead of large catch-all helpers.
- Place reusable MSW handlers in `src/tests/shared/handlers/`.
- Keep Maestro fixtures and factories inside `e2e/` only.
- E2E fixtures and factories must not be imported into Jest suites, and Jest shared support must not be imported into Maestro flows.

---

## 3. Unit Testing Standards

Unit tests target deterministic logic only.

Requirements:

- No native component rendering.
- No network calls.
- No dependency on app providers.
- Reuse shared factories from `src/tests/shared/factories/` when test data would otherwise be duplicated.

```ts
// src/tests/unit/format-currency.test.ts
import { describe, expect, it } from "@jest/globals";
import { formatCurrency } from "@/utils/format-currency";

describe("formatCurrency", () => {
  it("formats USD values", () => {
    expect(formatCurrency(1250)).toBe("$1,250.00");
    expect(formatCurrency(0)).toBe("$0.00");
  });
});
```

---

## 4. Integration Testing Standards

Integration tests verify user-visible behavior for screens and async state transitions.

Requirements:

- Render with React Native Testing Library.
- Mock network via MSW only.
- Use a dedicated QueryClient test provider, matching the pattern in `docs/frontend/testing.md`.
- Reuse modular factories and fixtures from `src/tests/shared/` instead of redefining render setup or test data per file.

```tsx
// src/tests/integration/dashboard-screen.test.tsx
import { render, screen } from "@testing-library/react-native";
import { describe, expect, it } from "@jest/globals";
import { DashboardScreen } from "@/features/dashboard/components/DashboardScreen";
import { QueryTestProvider } from "../shared/fixtures/query-test-provider";

describe("DashboardScreen", () => {
  it("renders metrics from mocked API handlers", async () => {
    render(
      <QueryTestProvider>
        <DashboardScreen />
      </QueryTestProvider>,
    );

    expect(await screen.findByText(/total revenue/i)).toBeTruthy();
  });
});
```

---

## 5. End-to-End Testing Standards (Maestro)

E2E flows validate critical user journeys on a real device or simulator.

Requirements:

- Cover authentication, authorization, and primary conversion flows.
- Prefer stable `testID` selectors over text-based selectors when text may change across locales.
- Use isolated setup for authenticated and unauthenticated states.
- Keep Maestro flows modular under `e2e/flows/`, with reusable setup in `e2e/fixtures/` and data seeding in `e2e/factories/`.

```yaml
# e2e/flows/dashboard.flow.yaml
appId: com.example.app
---
- launchApp
- tapOn: "Sign in"
- inputText: "developer@internal.local"
- tapOn: "Password"
- inputText: "SuperSecurePassword123"
- tapOn: "Sign in"
- assertVisible: "Total revenue"
```

---

## 6. What to Test for Each Change

Choose the smallest sufficient layer, then add broader coverage only when risk requires it.

- Utility or pure transform change: add or update unit tests.
- Screen/component state or async rendering change: add or update integration tests.
- Navigation flow, auth-protected route, or production-critical journey: add or update Maestro flows.

---

## 7. Flake Prevention Rules

- Do not use arbitrary sleeps; use RNTL async queries (`findBy*`, `waitFor`) and Maestro's built-in wait/assert behavior.
- Reset MSW handlers and shared state between tests.
- Avoid asserting implementation internals (component state, private methods).
- Keep tests independent and order-agnostic.

---

## 8. CI Expectations

Minimum merge quality gate:

- Unit and integration test suites pass.
- Maestro smoke flows pass for protected critical journeys.
- No skipped tests in changed areas unless documented in PR notes.
