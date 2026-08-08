# Convex Flow

Use neverthrow inside services and convert to a plain tuple only in the registered Convex handler. Let Convex's generated API carry the inferred return type to callers.

## Serializable tuple boundary

```ts
export type TupleResult<S, E extends { reason: string }> =
  | [error: E, data: null]
  | [error: null, data: S];

export function tupleOk<const S>(data: S): TupleResult<S, never> {
  return [null, data];
}

export function tupleErr<const E extends { reason: string }>(
  error: E,
): TupleResult<never, E> {
  return [error, null];
}
```

## Repository operations

Convex already propagates database failures as rejected function calls and rolls back mutations that throw. Keep those failures outside the expected business-error channel.

Use `ResultAsync.fromSafePromise` only to make the Promise chainable. Despite its name, it does not convert a rejection into an `Err`; the rejection still escapes to Convex.

```ts
import { ResultAsync } from "neverthrow";

function findRecord(ctx: QueryCtx | MutationCtx, recordId: Id<"records">) {
  return ResultAsync.fromSafePromise(
    ctx.db.get(recordId),
  );
}

function saveRecord(ctx: MutationCtx, record: Doc<"records">) {
  return ResultAsync.fromSafePromise(
    ctx.db
      .patch(record._id, { title: record.title })
      .then(() => record),
  );
}
```

Reserve `tryPromise` for failures that are intentionally recoverable product outcomes. Do not remap ordinary Convex database failures to errors such as `DATABASE_ERROR`.

## Business rules and service

```ts
function requireRecord(recordId: Id<"records">) {
  return function requireFound(record: Doc<"records"> | null) {
    if (record === null) {
      return err({
        reason: "RECORD_NOT_FOUND" as const,
        recordId,
      });
    }

    return ok(record);
  };
}

function requireEditable(record: Doc<"records">) {
  if (record.locked) {
    return err({
      reason: "RECORD_LOCKED" as const,
      recordId: record._id,
    });
  }

  return ok(record);
}

function applyUpdate(
  record: Doc<"records">,
  input: UpdateRecordInput,
) {
  return { ...record, title: input.title };
}

export function updateRecordService(
  ctx: MutationCtx,
  input: UpdateRecordInput,
) {
  return findRecord(ctx, input.recordId)
    .andThen(requireRecord(input.recordId))
    .andThen(requireEditable)
    .map((record) => applyUpdate(record, input))
    .andThen((record) => saveRecord(ctx, record));
}
```

Use small arrows only when a named step needs additional values such as `ctx` or `input`.

## Inline Convex handler

Convert the `ResultAsync` to the serializable tuple directly in the registered handler:

```ts
export const updateRecord = mutation({
  args: {
    recordId: v.id("records"),
    title: v.string(),
  },

  handler: (ctx, input) =>
    updateRecordService(ctx, input)
      .match(tupleOk, tupleErr),
});
```

Do not add a separate handler function or exported return type solely for frontend inference. Convex codegen exposes the handler's inferred return type through `api`.

## Frontend caller

Use a client helper that preserves expected tuple errors and converts rejected Convex calls into one unexpected variant:

```ts
export type UnexpectedError = {
  reason: "UNEXPECTED_ERROR";
};

export async function tryCatch<
  R extends TupleResult<unknown, { reason: string }>,
>(promise: Promise<R>): Promise<R | TupleResult<never, UnexpectedError>> {
  try {
    return await promise;
  } catch {
    return tupleErr({ reason: "UNEXPECTED_ERROR" });
  }
}
```

Type inference works directly from `useMutation`:

```ts
const updateRecord = useMutation(api.records.updateRecord);

const [error, record] = await tryCatch(
  updateRecord(input),
);

if (error !== null) {
  switch (error.reason) {
    case "RECORD_NOT_FOUND":
      showMessage("The record no longer exists.");
      return;

    case "RECORD_LOCKED":
      showMessage("The record is locked.");
      return;

    case "UNEXPECTED_ERROR":
      showMessage("Something unexpected happened.");
      return;

    default: {
      const exhaustive: never = error;
      return exhaustive;
    }
  }
}

showRecord(record);
```

## Mutation safety

Check every expected failure before the first write. Returning an expected `Err` after `ctx.db.patch`, `insert`, `replace`, or `delete` does not roll back an otherwise successful Convex mutation.
