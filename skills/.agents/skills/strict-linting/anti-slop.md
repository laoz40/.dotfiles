# anti-slop plugin

Optional oxlint plugin from [dmmulroy/anti-slop](https://github.com/dmmulroy/anti-slop):
opinionated rules that reject low-evidence, low-signal TypeScript patterns.
The philosophy is **type-safety evidence** — code must not fabricate certainty
(unsafe casts), widen known types into `unknown`, or narrow ad hoc with
runtime `typeof`. Parse boundaries with a schema instead.

## Setup

The plugin is meant to be **vendored**, not installed as a dependency: copy
the source into the repo, read each rule, and adapt it to the team's
standards. Requires the `@oxlint/plugins` package (`eslintCompatPlugin`
wraps the rules for oxlint's JS-plugin API).

1. Copy the upstream `src/` into the repo, e.g. `tools/oxlint/anti-slop/`.
2. Register it in the root lint config:

   ```json
   "jsPlugins": [{ "name": "anti-slop", "specifier": "./tools/oxlint/anti-slop/index.ts" }]
   ```

3. Add the plugin directory to `ignorePatterns` so the linter does not lint
   its own rule implementations.
4. Enable rules individually under the `anti-slop/` prefix, one at a time.
   Enable the rules the codebase already satisfies first — they lock in the
   floor for free — then refactor toward the rest in increments like any
   other adoption.

## Rules

Fifteen generic rules:

- `no-chained-type-assertions` — blocks stacked casts like `x as object as User`.
- `no-widen-then-assert` / `no-known-value-widening` — block widening a known
  shape to a broad type just to cast it back; prefer `satisfies`.
- `require-safety-comment-for-type-assertion` — non-`const` assertions need a
  `// SAFETY:` comment stating the invariant. Pairs with the type-aware
  `no-unsafe-type-assertion`: together every cast must state and hold evidence.
- `no-unknown-parameters` / `no-unknown-returns` / `no-object-parameters` —
  signatures must be honest; narrow at the boundary instead.
- `no-unknown-type-aliases` / `no-unsafe-dictionary-type` — no hiding `unknown`
  behind an alias, no `Record<string, any>` dictionaries.
- `no-runtime-typeof` — runtime `typeof` narrowing gives way to boundary
  parsing (optionally allowed in type guards).
- `no-module-mocking` — bans `vi.mock` / `jest.mock`; push a dependency seam
  instead.
- `no-reflect-get` / `no-reflect-apply` — typed property access and calls over
  reflection.
- `no-conditional-empty-object-spread` — blocks `...(cond ? { x } : {})`.
- `no-shape-in-symbol-names` — no shape jargon baked into identifier names.

One opt-in **Effect** rule, `no-service-constructor-imports`: callers must
import the owning Layer and yield the service rather than the
`make<CapabilityName>` constructor (test files exempt). Adopt only in
Effect-TS codebases.
