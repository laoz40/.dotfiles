---
name: strict-linting
description: >
  Strict oxlint and TypeScript toolchain: warnings to errors, type-aware
  linting, complexity limits, tsconfig strict flags. Use when setting up or
  tightening linting or code-quality enforcement.
disable-model-invocation: true
---

# Strict linting

Machine-enforced code quality. The lint config and compiler flags are the
enforcement layer that keeps agent-written code maintainable: no dead code, no
loose equality, no oversized functions, no silent `undefined` from indexed
access. The toolchain exists so an LLM agent working in the codebase is
constrained toward the same quality bar a careful human would hold.

Two hard guardrails:

- **Errors only.** Every rule fires at `"error"` severity; the linter reports
  zero warnings. A warning is a rule the team has agreed to ignore.
- **No suppressions.** State the positive target instead: tune the rule's
  options, add a scoped per-file override with a justified limit, or fix the
  code. Inline `eslint-disable` / ignore comments are banned.

## Process

Adopt **incrementally**: one change, run the check, count violations, resolve
them (fix code or tune config), then the next increment. Each increment is
done when the full check passes with zero errors.

### 1. Severity: warnings become errors

Replace every `"warn"` with `"error"` in the lint config. Then verify the
config is actually loaded: plant a deliberate violation in a temp file (e.g.
`var x = 1;` in a `.ts` file), confirm the linter errors, delete the file.
A silently unread config makes every later step meaningless.

### 2. Categories: enable in tiers

In oxlint, set categories in `categories` (explicit `rules` entries override
categories):

- `"correctness": "error"`, `"suspicious": "error"`, `"perf": "error"` —
  enable wholesale. These are the bug-catching tiers with low false-positive
  rates.
- **pedantic** and **restriction** — explore with `oxlint --rules` and adopt
  rules individually, so each earns its place with a known reason. This is
  where the quality-pushers live: `eqeqeq`, `array-callback-return`,
  `complexity`, `max-lines`, `max-statements`.
- **nursery** — the exploration tier: new rules still settling into permanent
  categories. Review its list when adopting, and opt in rules that fit the
  codebase once proven quiet.

Expect fallout to triage **fix-vs-tune**: legitimate patterns revealed as
config gaps get tuned in the config (e.g. side-effect imports like
`import "server-only"` or `import "./globals.css"` get an `allow` glob on
`import/no-unassigned-import`), genuine findings get fixed in code. The
default is fix the code; a config tune needs a one-line justification.

### 3. Size and complexity limits

Add to the lint rules:

```json
"complexity": ["error", { "max": 12 }],
"max-depth": ["error", { "max": 3 }],
"max-statements": ["error", { "max": 15 }],
"max-lines": ["error", { "max": 400, "skipBlankLines": true, "skipComments": true }]
```

`max-lines` counts imports and types too — its only options are `max`,
`skipBlankLines`, `skipComments`. When a file trips it, extract a cohesive
section into a new file rather than raising the limit.

### 4. Hand-picked rules

```json
"eqeqeq": "error",
"array-callback-return": "error",
"default-case": "error",
"class-methods-use-this": "error"
```

Low-noise silent-bug catchers: loose equality, a `map`/`filter` callback that
forgets to return, switch fallthrough, and class methods that ignore `this`.

### 5. Type-aware linting

Add the `oxlint-tsgolint` dev dependency and set `"options": { "typeAware":
true }` in the root lint config (root-config only; the `--type-aware` CLI flag
overrides it). tsgolint (Go, built on typescript-go) runs the type-aware
rules, while oxlint keeps traversal, config, and reporting. Requires
TypeScript 7.0+ (the native compiler).

Type-aware rules use the same `@typescript-eslint/` prefix as the rest — the
type information just unlocks a stricter set. Start with the cast-policing
quartet plus two regression guards:

```json
"@typescript-eslint/no-unsafe-type-assertion": "error",
"@typescript-eslint/no-unnecessary-type-assertion": "error",
"@typescript-eslint/no-unsafe-argument": "error",
"@typescript-eslint/non-nullable-type-assertion-style": "error",
"@typescript-eslint/require-await": "error",
"@typescript-eslint/switch-exhaustiveness-check": "error"
```

Adopt one rule at a time, same discipline as the tsconfig flags. Fallout from
`no-unsafe-type-assertion` — the flagship — usually reveals a missing Zod
parse or guard at a boundary, not a bad cast to silence. Browse the
implemented-rules list in github.com/oxc-project/tsgolint (e.g.
`no-floating-promises`, `unbound-method`) and adopt what fits.

### 6. TypeScript compiler flags, one at a time

Add to `tsconfig.json` one flag at a time, running `tsc --noEmit` after each:

```jsonc
"noUncheckedIndexedAccess": true,   // arr[i] is T | undefined — the highest-value flag, especially for stats/numeric code
"noFallthroughCasesInSwitch": true, // zero-noise switch fallthrough catcher
"noImplicitOverride": true,         // override keyword required on parent overrides
"verbatimModuleSyntax": true        // forces import type for type-only imports
```

`verbatimModuleSyntax` flags existing imports with TS1484 — pure-type imports
become `import type { ... }`, mixed lines keep the value imports and add the
inline `type` modifier (`import { schema, type Foo }`). Mechanical, zero
behavior change.

Beyond these four, TypeScript ships more opt-in strictness flags — browse the
flag list when adopting and evaluate any that fit the codebase, with the same
one-at-a-time typecheck discipline.

## Optional plugin: anti-slop

An oxlint plugin of opinionated rules that reject low-evidence TypeScript
patterns (chained casts, `unknown`/`object` signatures, known-value widening,
module mocking). It is optional — adopt when the user asks for anti-slop or
slop-pattern enforcement. Setup, rule list, and adoption order live in
[`anti-slop.md`](anti-slop.md).

## Vendored UI components (shadcn)

Vendored shadcn internals legitimately trip app-code rules (e.g.
`InputGroupAddon`'s click-to-focus `div` with `tabIndex`), and fixing them
means diverging from upstream. Scope an override to the vendored directory
instead — the rules stay active in app code:

```json
{
	"files": ["components/ui/**"],
	"plugins": ["jsx-a11y"],
	"rules": {
		"jsx-a11y/no-noninteractive-tabindex": "off",
		"jsx-a11y/no-noninteractive-element-interactions": "off"
	}
}
```

Keep the off-list minimal — one rule at a time, one-line justification. A
rule whose hits are all false positives (e.g. `prefer-tag-over-role` vs the
WAI-ARIA combobox pattern) never earns its place: turn it off globally with
a justification.

## oxlint gotchas

- `oxlint --rules` lists every rule with its category, default state, and
  fixability — the source of truth for what a category contains.
- Rule options are often absent from `configuration_schema.json`. Test
  empirically: an unknown option field produces a hard config error listing
  the valid fields, so a quick lint run settles what a rule accepts.
- oxlint's JSON parser accepts trailing commas (JSONC-style).
- **A rule can only be configured in a scope where its plugin is enabled.**
  If a plugin (e.g. `jsx-a11y`) is declared inside an override rather than at
  the top level, a top-level `rules` entry for that plugin is silently
  ignored — no error, no effect. Put the entry in the override that declares
  the plugin. Override `plugins` add to the enabled set; they don't replace
  it.
- `no-undef` and `no-unreachable` sit in **nursery**, so enabling
  correctness leaves them off — enable them explicitly when wanted.
- Rules that merely duplicate what the TypeScript compiler catches
  (`constructor-super`, `no-const-assign`, `no-redeclare`, …) belong in a
  TS-files override at `"off"` — they are redundant there, not suppressed.
