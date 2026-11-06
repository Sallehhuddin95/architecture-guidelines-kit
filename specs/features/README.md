# Feature Specs

Feature specs describe a business capability from the product and implementation point of view.

Use one file per feature or bounded feature slice.

---

## Template

```md
# Feature Name

## Status

Draft

## Goal

What problem does this feature solve?

## Scope

What is included?

## Out of Scope

What is explicitly not included?

## Actors

Who uses or triggers this feature?

## Preconditions

What must already be true?

## Main Flow

Describe the expected behavior step by step.

## Alternate Flows

Describe important branching behavior.

## Error and Empty States

What happens when data is missing, invalid, unavailable, or forbidden?

## Acceptance Criteria

Write criteria in EARS notation (`THE SYSTEM SHALL ...`) with
`Given / When / Then` scenarios for behavior:

- REQ-001 (Ubiquitous): THE SYSTEM SHALL [always-active invariant].
- REQ-002 (Event-Driven): WHEN [trigger event] THE SYSTEM SHALL [system response].
- REQ-003 (State-Driven): WHILE [system state is active] THE SYSTEM SHALL [system response].
- REQ-004 (Unwanted Behavior): IF [error condition] THEN THE SYSTEM SHALL [error handling response].

```md
### Scenario 1: [Happy Path Name]
- Given [precondition]
- When [actor action]
- Then [observable outcome and state change]
```

## Traceability

Link each feature spec to its corresponding files:

- API: `specs/api/[slice].md`
- Database: `specs/database/[slice].md`
- UI: `specs/ui/[slice].md`
- Acceptance: `specs/acceptance/[slice].md`

If a linked file does not exist yet, name it here so the change bundle
creating this feature knows what to produce.

## Related Specs

- API:
- UI:
- Acceptance:
```

---

## Writing Rules

- Keep the feature goal explicit.
- Define scope and out-of-scope behavior clearly.
- Include important empty, failed, unauthorized, or retry behavior.
- Write acceptance criteria in observable terms.
