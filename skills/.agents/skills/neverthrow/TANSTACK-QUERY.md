# TanStack Query Flow

Keep neverthrow inside backend services. At the backend handler, convert the service's `Result` into the transport's native success and error channels. The frontend client then resolves with data or rejects with a typed transport error.

## React query component

Keep the query call and its options together in the component:

```tsx
import { isDefinedError } from "@orpc/client";
import { useQuery } from "@tanstack/react-query";

export function RecordPage({ recordId }: { recordId: string }) {
  const query = useQuery(
    orpc.records.get.queryOptions({
      input: { recordId },

      retry: (failureCount, error) => {
        if (!isDefinedError(error)) {
          return failureCount < 2;
        }

        switch (error.code) {
          case "UNAVAILABLE":
            return failureCount < 2;

          case "RECORD_NOT_FOUND":
          case "FORBIDDEN":
            return false;

          default: {
            const exhaustive: never = error;
            return exhaustive;
          }
        }
      },
    }),
  );

  if (query.isPending) {
    return <p>Loading record…</p>;
  }

  if (query.isError) {
    const error = query.error;

    if (!isDefinedError(error)) {
      return (
        <button type="button" onClick={() => query.refetch()}>
          Something went wrong. Try again
        </button>
      );
    }

    switch (error.code) {
      case "RECORD_NOT_FOUND":
        return <p>Record {error.data.recordId} was not found.</p>;

      case "FORBIDDEN":
        return <p>You do not have access to this record.</p>;

      case "UNAVAILABLE":
        return (
          <button type="button" onClick={() => query.refetch()}>
            Service unavailable. Try again
          </button>
        );

      default: {
        const exhaustive: never = error;
        return exhaustive;
      }
    }
  }

  return <h1>{query.data.title}</h1>;
}
```

The transport integration supplies the query function, success type, and error type. TanStack Query handles loading, caching, retries, and error state.

The exact narrowing helper depends on the typed transport. For oRPC v1 use `isDefinedError`; other integrations may provide a different helper.

## Mutations

Handle mutation errors in the same native error channel:

```tsx
const mutation = useMutation(
  orpc.records.update.mutationOptions({
    onError: (error) => {
      if (!isDefinedError(error)) {
        showMessage("Something unexpected happened.");
        return;
      }

      switch (error.code) {
        case "RECORD_NOT_FOUND":
          showMessage("The record no longer exists.");
          return;

        case "RECORD_LOCKED":
          showMessage("The record is locked.");
          return;

        case "UNAVAILABLE":
          showMessage("The record could not be saved.");
          return;

        default: {
          const exhaustive: never = error;
          return exhaustive;
        }
      }
    },
  }),
);
```

## Rules

- Keep `Result` and `ResultAsync` inside backend services.
- Convert service errors once in the backend transport handler.
- Use the transport's generated TanStack Query options directly.
- Represent responses through the transport's native success and typed error channels.
- Distinguish declared product errors from unexpected transport or programming errors.
- Handle declared errors with an exhaustive switch.
- Retry transient failures.
