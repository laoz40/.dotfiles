# Complete Flow

This example keeps neverthrow inside application code and returns a plain serializable union at the boundary.

## Errors

Return plain objects with a literal `reason`. Let TypeScript infer each error type from the service pipeline.

```ts
function databaseError(cause: unknown) {
  return {
    reason: "DATABASE_ERROR" as const,
    cause,
  };
}
```

## Repository

Repositories capture throwing or rejecting infrastructure operations with `tryPromise` and return `ResultAsync`.

```ts
function findRecord(id: string) {
  return tryPromise({
    try: () => database.records.findById(id),
    catch: databaseError,
  });
}

function saveRecord(record: Record) {
  return tryPromise({
    try: () =>
      database.records
        .update(record.id, record)
        .then(() => record),
    catch: databaseError,
  });
}
```

The final `.then(() => record)` only chooses the successful value. `tryPromise` handles synchronous throws and Promise rejections.

## Business rules

Each fallible rule returns `ok` or `err`. Preserve the successful value when the next step still needs it.

```ts
import { err, ok } from "neverthrow";

function requireRecord(recordId: string) {
  return function requireFound(record: Record | null) {
    if (record === null) {
      return err({
        reason: "RECORD_NOT_FOUND" as const,
        recordId,
      });
    }

    return ok(record);
  };
}

function requireEditable(record: Record) {
  if (record.locked) {
    return err({
      reason: "RECORD_LOCKED" as const,
      recordId: record.id,
    });
  }

  return ok(record);
}
```

## Service

Prefer named functions in the chain. Use a small arrow only to provide an additional input value.

```ts
type UpdateRecordInput = {
  recordId: string;
  title: string;
};

function applyUpdate(record: Record, input: UpdateRecordInput): Record {
  return { ...record, title: input.title };
}

export function updateRecordService(input: UpdateRecordInput) {
  return findRecord(input.recordId)
    .andThen(requireRecord(input.recordId))
    .andThen(requireEditable)
    .map((record) => applyUpdate(record, input))
    .andThen(saveRecord);
}
```

Flow behavior:

```text
Ok from a step  -> pass its value to the next callback
Err from a step -> skip every remaining callback
map              -> transform an Ok with an infallible function
andThen          -> run a function returning Result or ResultAsync
```

## Framework boundary

Do not invent a custom serializable Result envelope unless the transport requires one. With a typed RPC framework, return the success value and translate service errors into the framework's defined error channel.

```ts
export async function updateRecordHandler(input: UpdateRecordInput) {
  const result = await updateRecordService(input);

  return result.match(
    (record) => record,
    (error) => {
      switch (error.reason) {
        case "RECORD_NOT_FOUND":
          throw frameworkErrors.notFound({
            recordId: error.recordId,
          });

        case "RECORD_LOCKED":
          throw frameworkErrors.conflict({
            recordId: error.recordId,
          });

        case "DATABASE_ERROR":
          throw frameworkErrors.unavailable();

        default: {
          const exhaustive: never = error;
          return exhaustive;
        }
      }
    },
  );
}
```

`frameworkErrors` represents the typed errors supplied by the selected RPC or web framework. Do not expose internal causes or database details.

If a boundary supports Result instances directly, return the Result without conversion. If it requires serializable values, use its native serializer or adapt once at that boundary.

## Exhaustive caller handling

Use the framework's typed safe-call API, then exhaustively handle its public error codes. The exact safe-call shape depends on the framework.

```ts
async function submitUpdate(input: UpdateRecordInput) {
  const { data, error } = await safeCallUpdateRecord(input);

  if (!error) {
    showRecord(data);
    return;
  }

  switch (error.code) {
    case "NOT_FOUND":
      showMessage("The record no longer exists.");
      return;

    case "CONFLICT":
      showMessage("The record is locked and cannot be edited.");
      return;

    case "UNAVAILABLE":
      showMessage("The record could not be saved. Try again.");
      return;

    default: {
      const exhaustive: never = error;
      return exhaustive;
    }
  }
}
```

Adding a defined error must make exhaustive boundary handling fail type-checking until its policy is implemented.
