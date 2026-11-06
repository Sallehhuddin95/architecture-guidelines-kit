// Starter dependency-cruiser config enforcing
// docs/architecture/dependency-rules.md and module-boundaries.md.
// Copy into a TypeScript project (Next.js, Angular, React Native,
// Express) and adjust `path` scopes to the project's layout.
// Requires: npm i -D dependency-cruiser
/** @type {import('dependency-cruiser').IConfiguration} */
module.exports = {
  forbidden: [
    {
      name: 'no-circular',
      severity: 'error',
      comment: 'Circular dependencies across modules are forbidden.',
      from: {},
      to: { circular: true },
    },
    {
      name: 'no-cross-feature-imports',
      severity: 'error',
      comment:
        'A feature slice may not reach into another slice internals. ' +
        'Cross-feature use must go through the target public barrel (index).',
      from: { path: 'src/features/([^/]+)/.+' },
      to: {
        path: 'src/features/([^/]+)/.+',
        pathNot: 'src/features/$1/(index\\.(ts|tsx|js|jsx)|.+\\.d\\.ts)$',
      },
    },
    {
      name: 'ui-cannot-import-data-layer-directly',
      severity: 'error',
      comment:
        'UI components must not import the data layer directly. ' +
        'Go through services/hooks/stores per the stack guideline.',
      from: {
        path: 'src/(features/[^/]+/(components|views|pages)|components|app)/.+',
      },
      to: {
        path: 'src/(features/[^/]+/(repositories|api-client|db)|lib/db|server/db)/.+',
      },
    },
  ],
  options: {
    doNotFollow: { path: 'node_modules' },
    tsPreCompilationDeps: true,
    tsConfig: { fileName: 'tsconfig.json' },
  },
};
