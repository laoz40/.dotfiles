# Guardrail settings

These settings describe the required policy. Adapt config wrappers and paths to the installed tooling and project, while preserving the rule values.

## Oxlint and Ultracite

Extend `ultracite/oxlint/core` and `ultracite/oxlint/anti-slop`. Add the React, TanStack, or other framework presets only when applicable. Place custom rules after presets so they remain authoritative. Preserve anti-slop's intentional compatibility overrides.

Register the anti-slop JavaScript plugin, using the preset's exported `jsPlugins` when supported. Merely extending a preset is insufficient if its plugin never loads. Use Ultracite's bundled anti-slop implementation when available. Do not invent an npm package for upstream anti-slop.

Enable categories `correctness`, `suspicious`, and `perf` at `error`. Enable root-level type-aware analysis for TypeScript with the compatible `oxlint-tsgolint` package.

Retain these explicit rules even when a preset duplicates them:

```json
{
  "@typescript-eslint/no-unsafe-type-assertion": "error",
  "@typescript-eslint/no-unnecessary-type-assertion": "error",
  "@typescript-eslint/no-unsafe-argument": "error",
  "@typescript-eslint/non-nullable-type-assertion-style": "error",
  "@typescript-eslint/require-await": "error",
  "@typescript-eslint/switch-exhaustiveness-check": "error",
  "@typescript-eslint/no-floating-promises": "error",
  "no-var": "error",
  "no-warning-comments": "error",
  "eqeqeq": "error",
  "array-callback-return": "error",
  "default-case": "error",
  "class-methods-use-this": "error",
  "complexity": ["error", { "max": 15 }],
  "max-depth": ["error", { "max": 3 }],
  "max-statements": ["error", { "max": 15 }],
  "max-lines": ["error", { "max": 500, "skipBlankLines": true, "skipComments": true }],
  "no-nested-ternary": "error",
  "no-undef": "error",
  "no-unreachable": "error"
}
```

For React's automatic JSX runtime, set `react/react-in-jsx-scope` to `off`.

### Shadcn design rules

For shadcn projects, register `@shadcn/lint` alongside anti-slop's JavaScript plugins, and set each rule to `error`:

```json
{
  "shadcn/no-restyle": "error",
  "shadcn/no-raw-colors": "error",
  "shadcn/no-arbitrary-values": "error",
  "shadcn/no-inline-styles": "error",
  "shadcn/no-unknown-classes": "error",
  "shadcn/require-static-classes": "error"
}
```

Exclude actual vendored component internals from application lint policy. Continue linting application wrappers and usage sites. Verify any design-system configuration the installed plugin requires.

## Formatter

Spread `ultracite/oxfmt` first, then apply these exact overrides:

```json
{
  "printWidth": 100,
  "semi": true,
  "trailingComma": "none",
  "singleQuote": false,
  "jsxSingleQuote": false,
  "arrowParens": "always",
  "bracketSpacing": true
}
```

Inherit indentation and layout defaults instead of overriding `tabWidth`, `useTabs`, `objectWrap`, `bracketSameLine`, `singleAttributePerLine`, or `sortPackageJson`. Ultracite 8.0.0 uses two spaces and enables package JSON sorting. Verify the installed preset when upgrading.

For Tailwind projects, enable `sortTailwindcss` with the actual stylesheet path and class helper functions, usually `["cn"]`. Do not copy a nonexistent `src/styles.css` into configuration.

Preserve preset ignores and exclude dependency directories, build output, generated files, lockfiles, and vendored UI. The preferred formatter policy also excludes `**/*.md`, `**/*.yaml`, and `**/*.yml`. Keep the source exclusions narrow and project-specific.

## TypeScript

Enable these compiler options in every applicable package, either directly or through an inherited shared config:

```json
{
  "strict": true,
  "noUnusedLocals": true,
  "noUnusedParameters": true,
  "noUncheckedIndexedAccess": true,
  "noFallthroughCasesInSwitch": true,
  "noImplicitOverride": true,
  "verbatimModuleSyntax": true,
  "exactOptionalPropertyTypes": true
}
```

Choose target, module resolution, JSX, runtime types, and emit settings for the real framework. Write first-party tooling in TypeScript and include it in type checking alongside application source. Ensure workspace packages actually inherit the strict options.

## Fallow

Use a root Fallow config with these policies, adapting the schema path to the installation:

```json
{
  "rules": {
    "unused-files": "error",
    "unused-exports": "error",
    "unused-types": "error",
    "circular-dependencies": "error",
    "re-export-cycle": "error"
  },
  "duplicates": { "mode": "mild" }
}
```

Run both `fallow dead-code --fail-on-issues` and `fallow dupes --fail-on-issues`. Configure framework entry points and workspace boundaries so Fallow analyzes real application code. Scope duplicate exclusions to generated or vendored paths.

Declare dynamically loaded lint plugins and type-analysis tools as ignored dependencies only when Fallow cannot infer their use. Explain each entry. Do not inherit sample utility-file exclusions or blanket-ignore application code to clear findings.

## Suppression check

Copy [scripts/check-suppressions.ts](../scripts/check-suppressions.ts) into the project's `scripts/` directory rather than regenerating it. Run it from the repository root with `node scripts/check-suppressions.ts` on Node 22.18+ or `bun scripts/check-suppressions.ts`. Include it in the TypeScript check.

The checker scans TypeScript across the repository, excludes itself and dependency/build directories, and reports forbidden suppression markers with file and line before exiting nonzero. Adapt its `exclude` list for actual generated and vendored paths. This text-based check also matches marker text in string literals. Keep it before Oxlint in the lint command.

## Script and CI contract

Expose equivalent local commands through the project's package manager:

| Script | Required behavior |
| --- | --- |
| `format` | Apply the configured Oxfmt formatting |
| `format:check` | Check formatting without modifying files |
| `lint` | Run the suppression check and Oxlint with `--deny-warnings --report-unused-disable-directives-severity error` |
| `lint:fix` | Apply safe Oxlint fixes with the same configuration |
| `typecheck` | Check every applicable package without emitting application artifacts |
| `dead-code` | Run Fallow dead-code checks and fail on findings |
| `dupes` | Run Fallow duplicate checks and fail on findings |
| `check` | Run all applicable checks above, excluding fixing commands |
| `build` | Build the real application or package |

Use `vp lint` and `vp fmt` with Vite Plus, or direct `oxlint` and `oxfmt` commands otherwise. Ensure alternate commands, editor integration, and CI resolve the same configs.

For GitHub Actions, run on pull requests, pushes to the default branch, and `merge_group`. Adapt equivalent coverage to another CI provider. Use read-only repository permissions, concurrency cancellation, a bounded timeout, pinned supported runtimes, and a frozen lockfile install. Run a build plus every applicable check as failing steps. Generate framework types before checks that require them. Never use `continue-on-error` to make a required guardrail advisory.

Do not introduce pre-commit hooks as part of this skill. CI is the required enforcement point.

## Verification

- Run the full build and check suite using the project's supported runtime and package manager.
- Confirm effective config includes the custom rules, strict compiler flags, and relevant presets.
- Use temporary first-party probe files to verify anti-slop and, when applicable, shadcn plugin diagnostics. A config dump alone may omit JavaScript plugin rules. Remove probes even if a check fails.
- Confirm CI invokes every required check and uses the same config as local commands.
- For a new web app, start the dev server and verify that the intended route responds. A listening port alone does not prove the app works.
