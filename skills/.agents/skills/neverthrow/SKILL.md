---
name: neverthrow
description: Implements TypeScript neverthrow library, for better error handling using the Result type. Use when creating or refactoring services, handlers, or callers that use Result or ResultAsync.
---

# Neverthrow Services

## Core rules

- Represent expected failures with `Result` or `ResultAsync` and plain discriminated objects such as `{ reason: "NOT_FOUND" }`.
- Return `ok(value)` or `err(error)` from fallible synchronous business rules.
- Compose fallible steps with `.andThen()` so the first `Err` skips all remaining steps.
- Use `.map()` for infallible value transformations.
- Prefer named functions in chains: `.andThen(requireUser).map(buildOrder)`.
- Use a small arrow only when a step needs an additional argument: `.andThen((user) => loadAccount(user, input.accountId))`.
- Let TypeScript infer service success and error unions instead of duplicating them manually.
- Return only values callers use; return `null` for successful write-only steps.

## Promise boundary helper

Use this helper to convert a throwing or rejecting Promise operation into a chainable `ResultAsync`:

```ts
import { ResultAsync } from "neverthrow";

type TryPromiseOptions<T, E> = {
  try: () => Promise<T>;
  catch: (cause: unknown) => E;
};

export function tryPromise<T, E>(
  options: TryPromiseOptions<T, E>,
): ResultAsync<T, E> {
  return ResultAsync.fromPromise(
    Promise.resolve().then(options.try),
    options.catch,
  );
}
```

`Promise.resolve().then(options.try)` converts both synchronous throws and Promise rejections into the error mapped by `catch`.

Use `tryPromise` in repositories and external adapters:

```ts
function findRecord(id: string) {
  return tryPromise({
    try: () => database.find(id),
    catch: (cause) => ({ reason: "DATABASE_ERROR" as const, cause }),
  });
}
```

## Business rules

Keep expected business checks as small `Result`-returning functions:

```ts
function requireRecord(record: Record | null) {
  if (record === null) {
    return err({ reason: "RECORD_NOT_FOUND" as const });
  }

  return ok(record);
}
```

## Service pipeline

Write services as readable sequences of named operations:

```ts
export function updateRecordService(input: UpdateRecordInput) {
  return findRecord(input.id)
    .andThen(requireRecord)
    .andThen(requireEditable)
    .andThen((record) => loadDependency(record, input.dependencyId))
    .map((values) => applyUpdate(values, input))
    .andThen(saveRecord)
    .andThen(publishRecordUpdated);
}
```

Each `.andThen()` callback returns `Result` or `ResultAsync`. An `Err` propagates automatically; later callbacks do not run.

## Boundaries

- Do not invent a custom serializable Result envelope unless the transport requires one.
- At the outer handler, use the framework's native typed error channel and return the success value directly.
- Return Result instances directly when the boundary supports them; otherwise adapt once using the framework's serializer or error API.
- Handle expected error unions with an exhaustive switch on `error.reason` and a `never` default.
- Test each expected `Err`, successful values, and that later side effects are skipped after an error.

See [EXAMPLES.md](EXAMPLES.md) for a project-agnostic complete flow. For Convex, read [CONVEX.md](CONVEX.md) for inline handlers, tuple boundaries, inferred frontend types, and exhaustive caller handling.
