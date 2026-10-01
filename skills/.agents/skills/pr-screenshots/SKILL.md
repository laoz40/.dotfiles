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

Pick **one** layout. Do not mix broken relative markdown with `--attach`.

### Option A — Images only in the body (recommended)

1. Upload with `--attach` on create or edit, or copy asset URLs from the rendered PR on GitHub.
2. Put each image once in the body using **only** `user-attachments` URLs:

```md
![Popover open](https://github.com/user-attachments/assets/xxxxxxxx)
```

3. Do not duplicate the same image at the bottom unless the template requires it.

### Option B — Attach at create time with rewrite

On `gh pr create`, you may put `![Alt](./filename.png)` in the body **and** pass `--attach './filename.png#Alt'` for the same basename. `gh` may rewrite those references to the uploaded URL.

- Paths must match the attach basename exactly.
- After create, confirm images render on GitHub. Dead links mean Option A.

### Anti-pattern (do not do this)

- Body has `![label](./screenshot.png)` **and** you `--attach` the file without a successful rewrite.
- Result: dead links in the Evidence section and the same images again at the end.

Fix with `gh pr edit`: remove all `./…` image markdown, keep one set of `user-attachments` URLs in context, drop duplicate embeds at the bottom.

## `gh` examples

Create with attachments (Option B):

```sh
gh pr create --title "feat: …" --body-file body.md \
  --attach './tmp/evidence/view.png#Main view' \
  --attach './tmp/evidence/detail.png#Detail state'
```

Update body after you have asset URLs (Option A):

```sh
gh pr edit <number> --body-file body.md
```

Attach without replacing the body:

```sh
gh pr edit <number> --attach './tmp/evidence/new.png#New state'
```

Alt text: optional `#Description` after the path on `--attach`.
