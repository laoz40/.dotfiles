---
name: pr-screenshots
description: Capture UI evidence for pull requests and attach images to GitHub PRs with gh. Use when creating or updating a PR with screenshots, browser automation, authenticated pages, or gh pr --attach.
---

# PR UI evidence and GitHub images

## Assume the environment is ready

- **Default:** Credentials and config the app needs are already in the repo (`.env`, `.env.local`, etc.) or in the environment. Load them the way this project already does (package scripts, test config, `dotenv`, documented setup). Do not skip capture because the current shell session has no exports.
- **Start the app** when the UI is local (dev server, docker compose, preview URL). Reuse a server already listening on the expected port.
- **If capture still fails** after you tried (start app, follow project docs, read the error): tell the user what is missing (env var name, URL, login step). Do not guess that setup is impossible without attempting.

## Stop what you started

- Before you finish PR work (create, update, or hand off to the user), **shut down any dev server or compose stack you started** for screenshots. Do not leave background processes running.
- **Only stop processes you started** in this session. If the port was already in use when you began, treat that as the user's server and leave it running.
- Note how you started it so you can stop it the same way (foreground job in a terminal: interrupt or kill that PID; background shell: kill the recorded PID; `docker compose up`: `docker compose down` in that directory).
- If you are unsure whether you started it, check the terminal metadata (command, PID, cwd) before killing anything.

## Capture

1. Find URL, port, and auth from this repo only when it documents them (`README`, `AGENTS.md`, `CONTRIBUTING.md`, `package.json` scripts, `e2e/`, CI workflows).
2. **Protected routes:** A one-shot screenshot of a URL in a fresh browser often shows a login wall, not the feature. Use whatever this project provides: saved storage state, test login helpers, seeded sessions, or a short Playwright/Puppeteer script that signs in first. If nothing exists, sign in through the documented flow once, then capture.
3. If the repo has an existing script or test that already reaches the right screen, prefer that over a new ad-hoc flow.
4. Capture the changed UI (modal open, hover, error state, narrow viewport), not only the default landing view.
5. Before/after pairs: same route, viewport, and theme.

Playwright CLI is fine for public pages or after auth is handled:

```sh
npx playwright screenshot --full-page --wait-for-timeout 3000 <url> out.png
npx playwright screenshot --load-storage=path/to/state.json <url> out.png
```

Useful flags: `--wait-for-selector`, `--color-scheme dark`, `--device 'iPhone 11'`.

## Attach images to a GitHub PR

`gh pr create` and `gh pr edit` accept `--attach path/to.png#Alt text`. Uploaded files become `https://github.com/user-attachments/assets/...` URLs.

**Do not ship the PR until every screenshot in the description uses a `user-attachments` URL.** A body that mixes `![](./local.png)` with `![](https://github.com/user-attachments/assets/...)` is a failed run (one file uploaded, one left as a dead local path).

### Required workflow

1. Save captures under a stable path, e.g. `./tmp/evidence/dashboard-sessions.png`.
2. In `body.md`, each image must use the **same path string** you will pass to `--attach` (character-for-character). Wrong: body has `![](./dashboard-sessions.png)` while attach uses `./tmp/evidence/dashboard-sessions.png`. Right: both use `./tmp/evidence/dashboard-sessions.png`.
3. On `gh pr create`, pass one `--attach './tmp/evidence/dashboard-sessions.png#Alt text'` per image, matching `body.md` exactly.
4. Immediately after create, read the stored body and fix it before you return the PR URL:

```sh
gh pr view --json body -q .body
```

5. If the body still contains `](./` in any `![...](...)` image link, or duplicate image blocks at the end, run `gh pr edit` with a corrected body. Every image must be `![alt](https://github.com/user-attachments/assets/...)`. Copy asset URLs from the rendered PR on GitHub or from the rewritten body after a successful attach.

6. Do not use `gh pr edit --attach` to add more images unless you also replace the whole body in the same edit. `--attach` alone appends another embed at the bottom.

### Never put in a PR body

- Absolute paths on the machine
- A mix of `./…` and `user-attachments` URLs in the final description

### Anti-pattern (do not leave the PR like this)

```md
![Before](./dashboard-sessions.png)
![After](https://github.com/user-attachments/assets/4a2d3cca-41f2-437c-ba9b-4992770d7d95)
```

The first line does not render on GitHub. Fix both lines to `user-attachments` URLs and remove any extra copies `gh` appended at the bottom.
