# Convex flow

Use neverthrow inside services and lib. Convert results to a plain tuple only in the registered Convex handler. Let Convex's generated API carry the inferred return type to callers.

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

## Handler, service, and lib layers

Keep endpoint ordering in handlers, domain policy in services, and individual I/O operations and pure checks in lib. Read existing architecture docs and helper implementations before editing.

- Handlers own validators and step order. They call services only and finish tuple endpoints with `.match(tupleOk, tupleErr)`. Keep domain branches, DB calls, and lib imports out of handler files.
- Services compose lib functions and other services. Each exported function is one meaningful, reusable step. Services choose and enforce policy and invariants. Keep direct `ctx.db` access in lib.
- Authorization services load the caller's identity and access, choose the required permission, and compose pure lib checks. A lib check receives its inputs; it does not load them or choose which permission an endpoint requires.
- Lib contains individual DB operations and pure checks on supplied values. Split a function that loads data and then orchestrates domain work into a lib loader and a service that chains the checks and operations.
- Query and mutation services call lib directly, without `ctx.runQuery` or `ctx.runMutation`. Action services use registered functions when they need database access.
- Use concrete, verb-first names such as `getEditableRecord` or `updateRecordTitle`. Avoid generic `prepare`, `persist`, or `ensure` names. Do not rename existing functions outside the task's scope.
- Group related service steps by domain concept. Name files for their work, such as `recordQueries.ts` or `recordNotifications.ts`. Keep internal entrypoints beside the feature they serve.
- Create external clients inside the step that uses them. Do not pass client factory callbacks through service arguments.
- Avoid services that merely re-export or wrap one lib call. Fold the operation into a meaningful service step. Keep the handler's workflow visible instead of hiding it in one large service.
- Crons and internal entrypoints reuse the same service steps. Do not branch on which endpoint called a service using mode flags or endpoint-only optional arguments.

## Promise helpers

Centralize promise helpers in one lib module, such as `convex/lib/result.ts`, and reuse it. Keep direct `ResultAsync.fromSafePromise` and `ResultAsync.fromPromise` calls inside that helper module only.

| Operation | Helper | Failure behavior |
| --- | --- | --- |
| One Convex I/O expression, such as `ctx.db.*`, `ctx.auth.getUserIdentity()`, `ctx.scheduler.*`, or a raw `runQuery` / `runMutation` | `okOrThrow(promise)` | Unexpected rejection escapes to Convex |
| `runQuery` / `runMutation` returning a serialized tuple | `fromConvexTuple(promise)` | Tuple error becomes `Err`; unexpected rejection escapes |
| External API, such as Stripe, Resend, Google, fetch, DNS, or rendering | `tryPromise({ try, catch })` | `catch` returns a domain error object |

`tryPromise` catches synchronous throws in its `try` callback too. Its `catch` returns the error value, such as `{ reason: "EMAIL_REQUEST_FAILED" as const }`, not `err(...)`, and never rethrows. Resolved API responses may still report failure; check those with `.andThen()` and return `err(...)`.

Use `okOrThrow` on a single Convex I/O operation, not a whole async helper or workflow. Exported service and lib functions build `ResultAsync` from individual steps. Do not wrap an internal async implementation in `okOrThrow` or `tryPromise` to make its export appear compliant.

```ts
// convex/lib/records.ts
import { okOrThrow } from "./result";

export function getRecord(ctx: QueryCtx | MutationCtx, id: Id<"records">) {
  return okOrThrow(ctx.db.get("records", id));
}

export function patchRecordTitle(ctx: MutationCtx, id: Id<"records">, title: string) {
  return okOrThrow(ctx.db.patch("records", id, { title })).map(() => null);
}
```

## Service steps and handler

The following excerpts assume the project's generated context types and normal imports. Each service step adds domain meaning to lib operations.

```ts
// convex/services/records.ts
export function getEditableRecord(ctx: MutationCtx, id: Id<"records">) {
  return getRecord(ctx, id)
    .andThen(requireRecord)
    .andThen(requireEditable);
}

export function updateRecordTitle(ctx: MutationCtx, record: Doc<"records">, title: string) {
  return requireEditable(record)
    .andThen(() => patchRecordTitle(ctx, record._id, title));
}

// convex/records.ts
export const updateRecord = mutation({
  args: { recordId: v.id("records"), title: v.string() },
  handler: (ctx, input) =>
    requireRecordWriteAccess(ctx)
      .andThen(() => getEditableRecord(ctx, input.recordId))
      .andThen((record) => updateRecordTitle(ctx, record, input.title))
      .match(tupleOk, tupleErr),
});
```

`requireRecord` and `requireEditable` are pure lib checks returning `Result`. The former returns `RECORD_NOT_FOUND` for `null`; the latter returns `RECORD_LOCKED` for a locked record. `requireRecordWriteAccess` is an authorization service that loads the caller's access and returns `FORBIDDEN` when access is denied. The write step enforces editability itself so other handlers can reuse it safely.

Let errors propagate through `.andThen()` and `.map()`. Lib, email senders, and rate limiters return their real domain `reason` codes. Do not collapse them into synthetic service errors using `.mapErr()`. Group reasons in the client's switch when they share a message. Remove identity `.mapErr()` calls and passthrough switches.

Return `null` for successful write-only or fire-and-forget work. Preserve a value only when a later step or caller uses it.

## Tuple calls and inference

Action services convert internal tuple responses back into neverthrow before composing more work:

```ts
return fromConvexTuple(
  ctx.runMutation(internal.records.updateRecord, input),
).andThen((value) => sendRecordNotification(value));
```

Use `okOrThrow` for raw responses, not tuple responses. Otherwise a returned error tuple would remain an `Ok` value.

Prefer inferred return types. A service that references generated API functions from its own handler module may need an explicit `ResultAsync<Success, Error>` return type to break circular inference. Do not add a separate handler wrapper solely for frontend inference.

Paginated query handlers may return plain pagination when tuples would break Convex pagination. Keep individual reads inside service/lib steps wrapped with `okOrThrow`; do not wrap the whole pagination workflow.

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

const [error] = await tryCatch(
  updateRecord(input),
);

if (error !== null) {
  switch (error.reason) {
    case "FORBIDDEN":
      showMessage("You do not have access to edit this record.");
      return;

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

showMessage("Record updated.");
```

## Mutation safety

Check every expected failure before the first write. Returning an expected `Err` after `ctx.db.patch`, `insert`, `replace`, or `delete` does not roll back an otherwise successful Convex mutation.

## Review checks

- Every `okOrThrow` call wraps one Convex I/O expression.
- Every tuple-returning internal call uses `fromConvexTuple`.
- Every `tryPromise` wraps external work and its `catch` returns a domain error value.
- Handlers call services only and show the workflow as named steps.
- Services contain policy and compose lib calls, with no direct DB access.
- Lib loaders perform I/O; pure checks receive their inputs. Loading followed by domain orchestration belongs in services.
- Services preserve lower-layer error reasons.
- Exported lib functions compose steps rather than wrapping whole async implementations.
- Expected mutation failures are checked before writes.

Where the project has lint rules for these conventions, fix violations rather than adding ignore comments. When touching older code, apply these rules within the task's scope.
