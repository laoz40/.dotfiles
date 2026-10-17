---
name: project-setup
description: Set up a project with strict linting, formatting, static analysis, environment validation, and CI guardrails.
disable-model-invocation: true
---

# Project setup

Apply these conventions to a new or existing TypeScript project. Keep the result independent of any particular application, framework, package manager, or deployment provider.

## Required guardrails

- Use Oxlint with Ultracite's Oxlint core preset and Dillon Mulroy's anti-slop preset. Anti-slop is required, including its JavaScript plugin registration. Use framework presets only for frameworks the project uses.
- Use Oxfmt with Ultracite's formatter preset and the exact overrides in [guardrails.md](references/guardrails.md). Preserve the explicit custom lint rules even when a preset currently duplicates them.
- Enable type-aware linting, reject warnings, and reject unused disable directives. Enforce the strict TypeScript flags in the reference in every relevant package.
- Copy the bundled [suppression checker](scripts/check-suppressions.ts) into the project and run it before linting. Adapt its exclusions to actual generated and vendored paths. Fix the code or use a justified, narrowly scoped configuration override.
- Use Fallow for dead code, unused exports and types, dependency cycles, re-export cycles, and duplicate code. Findings must fail checks.
- In shadcn UI projects, register `@shadcn/lint` and enable all six design rules in the reference. Keep these rules active in application code. Do not add a UI framework to a backend or library merely to enable UI rules.
- Use T3 Env for environment variable validation. Select its package for the actual framework, or `@t3-oss/env-core` otherwise. Validate real variables at the application boundary, separate server and client variables, and expose only intentional public variables. Include a secret-free `.env.example` when variables exist. Do not invent variables to demonstrate setup.
- Run formatting, linting, type checking, Fallow dead-code checks, duplicate checks, and the build in CI. CI must fail on violations and use the same configuration and commands as local checks.

Read [guardrails.md](references/guardrails.md) when implementing these requirements. It contains the lint and formatter settings, static analysis policy, script contract, and verification criteria.

## Toolchain preferences

Prefer Bun and Vite Plus for a new project when they fit. Keep an existing package manager and build system unless the user asks to replace them. These preferences never justify a forced migration.

With Vite Plus, centralize `lint` and `fmt` in the root `vite.config.ts` and use `vp lint` and `vp fmt`. Without Vite Plus, configure Oxlint and Oxfmt directly using the installed versions' supported configuration format. Avoid competing config files or separate rule sets for different commands.

Pin compatible tooling and commit the lockfile. For Bun with Vite Plus, prefer the isolated linker and ensure the CLI and plugins resolve the same Vite runtime. Do not copy a project's version pins or aliases blindly. Verify the current supported setup and package exports before writing configuration.

## Workflow

1. Inspect project instructions, manifests, source roots, framework, existing checks, compiler configs, generated code, and CI. For an empty project, establish the intended project type before scaffolding it. Ask about unresolved choices that change behavior, UX, or architecture.
2. Read the guardrail reference and implement the required tooling using the chosen stack. Preserve application behavior. Keep optional integrations out of the initial install.
3. Scope generated and vendored exclusions to real paths. Explain each exclusion. Include all first-party application code, tooling, and workspace packages in checks.
4. Add the script contract and CI coverage from the reference. Adapt branch names, generation order, runtime versions, and package-manager commands to the project.
5. Run the build and every check. Repair findings without weakening the guardrails to produce a passing setup. Verify plugin loading with temporary violations, then remove the probes.
6. Report what changed, the checks run, and any unresolved blockers. Do not commit or publish unless requested.

When a requested feature needs an integration, read [optional-integrations.md](references/optional-integrations.md). These are preferences for later feature work, not an installation checklist.

## Sources to verify during setup

- [Ultracite presets](https://www.ultracite.ai/docs/presets) and [Dillon Mulroy's anti-slop](https://github.com/dmmulroy/anti-slop).
- [Oxlint documentation](https://oxc.rs/docs/guide/usage/linter) and [Vite Plus](https://viteplus.dev/).
- [T3 Env](https://env.t3.gg/) and [Fallow](https://github.com/fallow-rs/fallow).

Consult installed package exports and upstream documentation for version-specific APIs. Keep the required policies when adapting syntax.
