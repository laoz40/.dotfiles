# Optional integrations

Use these preferences when a feature calls for them. Add only the dependencies the feature needs, and respect the project's existing architecture and the user's explicit choices.

| Need | Preference |
| --- | --- |
| Authentication | Better Auth |
| Forms | TanStack Form |
| Hosted PostgreSQL | Neon |
| Error handling | Effect v4 |
| SQL | Effect v4 SQL |
| HTTP clients | Effect v4 HTTP client |
| Schema validation | Effect v4 Schema |
| Reactive state | Effect v4 Atom |
| RPC | Effect v4 RPC |

Verify Effect v4's current release status and package APIs before adoption. If the requested capability is unavailable or would require an architectural change, explain the choice and ask the user rather than silently substituting another major version or library.

T3 Env is part of the required project guardrails in [SKILL.md](../SKILL.md), rather than an optional integration.
