import { complete, type Message } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { access, readFile } from "node:fs/promises";
import { join, basename } from "node:path";
import { spawn } from "node:child_process";

const SYSTEM_PROMPT = `You generate GitHub pull request titles and descriptions.
Return only valid JSON in this shape:
{
  "title": "concise PR title",
  "body": "full markdown PR description"
}
Rules:
- Fill the provided PR template exactly, preserving its section headings.
- Use the branch diff, commits, and changed files as source of truth.
- Do not invent testing results. Only say a command/check passed, failed, or was manually verified when that evidence appears in user notes, validation results, recent chat context, commits, changed files, or diff.
- Treat the template's Testing section as validation, not only automated test suites. Include relevant evidence such as codegen, lint, typecheck/tsc, build checks, manual QA/user-flow verification, screenshots, browser/device checks, or known blocked checks.
- If no automated tests ran but other validation happened, list that validation instead of saying only "No tests".
- If no validation evidence is available, write "Not run" or state what still needs testing.
- Use Conventional Commit style for the title: type(optional-scope): concise subject.
- Valid title types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert.
- Keep the title under 72 characters when possible.
- Use a scope only when it adds clarity.
- Include useful reviewer notes when relevant.
- Do not include markdown fences or commentary outside JSON.`;

type PullRequestDraft = { title: string; body: string };
type ValidationCommand = { label: string; command: string; args: string[] };

function shellQuote(value: string): string {
  return `'${value.replace(/'/g, `'"'"'`)}'`;
}

function notifyDesktop(cwd: string, message: string): void {
  if (process.platform !== "linux") return;
  const child = spawn("notify-send", ["--hint", "string:suppress-sound:true", `Pi: ${basename(cwd) || cwd}`, message], {
    detached: true,
    stdio: "ignore",
  });
  child.unref();
}

function parseJsonDraft(text: string): PullRequestDraft | null {
  try {
    const jsonText = text.replace(/^```(?:json)?\s*/i, "").replace(/```$/i, "").trim();
    const parsed = JSON.parse(jsonText) as Partial<PullRequestDraft>;
    if (typeof parsed.title !== "string" || typeof parsed.body !== "string") return null;
    const title = parsed.title.trim();
    const body = parsed.body.trim();
    if (!title || !body) return null;
    return { title, body };
  } catch {
    return null;
  }
}

function truncateMiddle(value: string, max = 6000): string {
  if (value.length <= max) return value;
  const half = Math.floor((max - 20) / 2);
  return `${value.slice(0, half)}\n... truncated ...\n${value.slice(-half)}`;
}

async function pathExists(path: string): Promise<boolean> {
  try {
    await access(path);
    return true;
  } catch {
    return false;
  }
}

function extractText(value: unknown): string {
  if (typeof value === "string") return value;
  if (!value || typeof value !== "object") return "";
  if (Array.isArray(value)) return value.map(extractText).filter(Boolean).join("\n");

  const record = value as Record<string, unknown>;
  if (typeof record.text === "string") return record.text;
  if (typeof record.command === "string") return `$ ${record.command}`;
  if (typeof record.stdout === "string" || typeof record.stderr === "string") return [record.stdout, record.stderr].filter(Boolean).join("\n");
  if ("content" in record) return extractText(record.content);
  if ("message" in record) return extractText(record.message);
  if ("input" in record || "result" in record) return [extractText(record.input), extractText(record.result)].filter(Boolean).join("\n");
  return "";
}

function getRecentValidationContext(ctx: ExtensionCommandContext): string {
  const validationPattern = /\b(test|tested|testing|lint|typecheck|tsc|typescript|build|codegen|convex|manual|verified|qa|passes|passed|fails|failed|blocked|warning|error)\b/i;
  const entries = ctx.sessionManager.getBranch().slice(-80);
  const lines = entries
    .map((entry: unknown) => extractText(entry).trim())
    .filter((text) => validationPattern.test(text))
    .map((text) => truncateMiddle(text.replace(/\n{3,}/g, "\n\n"), 1200));

  return lines.slice(-20).join("\n\n---\n\n");
}

async function detectPackageManager(ctx: ExtensionCommandContext): Promise<{ command: string; runArgs: string[] } | null> {
  if (await pathExists(join(ctx.cwd, "pnpm-lock.yaml"))) return { command: "pnpm", runArgs: ["run"] };
  if (await pathExists(join(ctx.cwd, "yarn.lock"))) return { command: "yarn", runArgs: [] };
  if (await pathExists(join(ctx.cwd, "package-lock.json"))) return { command: "npm", runArgs: ["run"] };
  if (await pathExists(join(ctx.cwd, "package.json"))) return { command: "npm", runArgs: ["run"] };
  return null;
}

async function getValidationCommands(ctx: ExtensionCommandContext): Promise<ValidationCommand[]> {
  const packageManager = await detectPackageManager(ctx);
  if (!packageManager) return [];

  let scripts: Record<string, string> = {};
  try {
    const pkg = JSON.parse(await readFile(join(ctx.cwd, "package.json"), "utf8")) as { scripts?: Record<string, string> };
    scripts = pkg.scripts ?? {};
  } catch {
    return [];
  }

  const wanted = ["lint", "typecheck", "type-check", "tsc", "test"];
  return wanted
    .filter((script) => scripts[script])
    .map((script) => ({
      label: script,
      command: packageManager.command,
      args: [...packageManager.runArgs, script],
    }));
}

async function runValidation(pi: ExtensionAPI, ctx: ExtensionCommandContext): Promise<string> {
  const commands = await getValidationCommands(ctx);
  if (!commands.length) return "No package validation scripts detected.";

  const results: string[] = [];
  for (const check of commands) {
    ctx.ui.notify(`Running ${check.command} ${check.args.join(" ")}...`, "info");
    const result = await pi.exec(check.command, check.args, { signal: ctx.signal, timeout: check.label === "test" ? 120000 : 60000 });
    const status = result.code === 0 ? "passed" : `failed with exit code ${result.code}`;
    const output = truncateMiddle([result.stdout, result.stderr].filter(Boolean).join("\n").trim(), 5000);
    results.push(`$ ${check.command} ${check.args.join(" ")}\nStatus: ${status}${output ? `\nOutput:\n${output}` : ""}`);
  }

  return results.join("\n\n");
}

function fallbackDraft(template: string, branch: string, files: string, commits: string): PullRequestDraft {
  const subject = branch
    .replace(/^feature\//, "")
    .replace(/^feat\//, "")
    .replace(/^fix\//, "")
    .replace(/[-_]+/g, " ")
    .toLowerCase() || "update project";
  const title = `chore: ${subject}`;

  const changedFiles = files.trim() || "No changed files detected";
  const commitList = commits.trim() || "No commits detected";
  const body = template
    .replace("<!-- What does this PR do? -->\n\n-", `<!-- What does this PR do? -->\n\n- Updates ${branch}`)
    .replace("<!-- Why is this change needed? Link issues/context if relevant. -->\n\n-", "<!-- Why is this change needed? Link issues/context if relevant. -->\n\n- See branch context and commits")
    .replace("<!-- Main implementation details or notable files touched. -->\n\n-", `<!-- Main implementation details or notable files touched. -->\n\n- Changed files:\n${changedFiles.split("\n").map((file) => `  - ${file}`).join("\n")}`)
    .replace("<!-- Anything reviewers should know: trade-offs, follow-ups, risks, screenshots, etc. -->\n\n-", `<!-- Anything reviewers should know: trade-offs, follow-ups, risks, screenshots, etc. -->\n\n- Commits:\n${commitList.split("\n").map((commit) => `  - ${commit}`).join("\n")}`)
    .replace("<!-- How did you test this? Include commands, browsers/devices, or note if not tested. -->\n\n-", "<!-- How did you test this? Include commands, browsers/devices, or note if not tested. -->\n\n- Not run");

  return { title, body };
}

async function resolveCompareRef(pi: ExtensionAPI, ctx: ExtensionCommandContext, base: string): Promise<{ base: string; compareRef: string }> {
  const local = await pi.exec("git", ["rev-parse", "--verify", `${base}^{commit}`], { signal: ctx.signal, timeout: 5000 });
  if (local.code === 0) return { base, compareRef: base };

  const remote = await pi.exec("git", ["rev-parse", "--verify", `origin/${base}^{commit}`], { signal: ctx.signal, timeout: 5000 });
  if (remote.code === 0) return { base, compareRef: `origin/${base}` };

  return { base, compareRef: base };
}

async function chooseBaseBranch(pi: ExtensionAPI, ctx: ExtensionCommandContext, currentBranch: string): Promise<{ base: string; compareRef: string } | null> {
  const originHead = await pi.exec("git", ["symbolic-ref", "--short", "refs/remotes/origin/HEAD"], { signal: ctx.signal, timeout: 5000 });
  const defaultBase = originHead.code === 0 ? originHead.stdout.trim().replace(/^origin\//, "") : "";

  const refs = await pi.exec("git", ["for-each-ref", "--format=%(refname:short)", "refs/heads", "refs/remotes/origin"], { signal: ctx.signal, timeout: 5000 });
  const branches = refs.stdout
    .split("\n")
    .map((branch) => branch.trim())
    .filter(Boolean)
    .filter((branch) => branch !== "origin/HEAD")
    .map((branch) => branch.replace(/^origin\//, ""))
    .filter((branch) => branch !== currentBranch);

  const candidates = [...new Set([defaultBase, ...branches].filter(Boolean))];
  notifyDesktop(ctx.cwd, "Choose a PR base branch.");
  const selected = await ctx.ui.select("Choose PR base branch", candidates);
  if (!selected) return null;

  return resolveCompareRef(pi, ctx, selected);
}

async function generateDraft(ctx: ExtensionCommandContext, template: string, base: string, branch: string, files: string, commits: string, diff: string, notes: string, validation: string, chatContext: string): Promise<PullRequestDraft | null> {
  if (!ctx.model) throw new Error("No active model selected");

  const auth = await ctx.modelRegistry.getApiKeyAndHeaders(ctx.model);
  if (!auth.ok || !auth.apiKey) throw new Error(auth.ok ? `No API key for ${ctx.model.provider}` : auth.error);

  const notesSection = notes ? `User notes:\n${notes}\n\n` : "";
  const validationSection = validation ? `Validation results from commands run by /pr:\n${validation}\n\n` : "";
  const chatSection = chatContext ? `Recent chat/tool context that may mention validation. Prefer explicit user notes and fresh validation results over this if they conflict:\n${chatContext}\n\n` : "";
  const userMessage: Message = {
    role: "user",
    content: [{
      type: "text",
      text: `${notesSection}${validationSection}${chatSection}Base branch: ${base}\nCurrent branch: ${branch}\n\nPR template:\n${template}\n\nChanged files:\n${files}\n\nCommits:\n${commits}\n\nDiff:\n${diff.slice(0, 70000)}`,
    }],
    timestamp: Date.now(),
  };

  const response = await complete(
    ctx.model,
    { systemPrompt: SYSTEM_PROMPT, messages: [userMessage] },
    { apiKey: auth.apiKey, headers: auth.headers, signal: ctx.signal },
  );

  if (response.stopReason === "aborted") return null;
  const text = response.content
    .filter((part): part is { type: "text"; text: string } => part.type === "text")
    .map((part) => part.text)
    .join("\n");

  return parseJsonDraft(text);
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("pr", {
    description: "Generate a GitHub PR body from the project template and insert a gh pr create command. Usage: /pr [base-branch] [notes]",
    handler: async (args: string, ctx: ExtensionCommandContext) => {
      await ctx.waitForIdle();

      const [maybeBase, ...noteParts] = args.trim().split(/\s+/).filter(Boolean);

      const templatePath = join(ctx.cwd, ".github", "pull_request_template.md");
      let template: string;
      try {
        template = await readFile(templatePath, "utf8");
      } catch {
        ctx.ui.notify(`No PR template found at ${templatePath}`, "error");
        return;
      }

      const branchResult = await pi.exec("git", ["branch", "--show-current"], { signal: ctx.signal, timeout: 5000 });
      const branch = branchResult.stdout.trim();
      if (!branch) {
        ctx.ui.notify("Could not determine current git branch.", "error");
        return;
      }

      const hasExplicitBase = Boolean(maybeBase && !maybeBase.includes(":"));
      const selectedBase = hasExplicitBase ? await resolveCompareRef(pi, ctx, maybeBase) : await chooseBaseBranch(pi, ctx, branch);
      if (!selectedBase) return;
      const { base, compareRef } = selectedBase;
      const notes = hasExplicitBase ? noteParts.join(" ") : args.trim();

      const filesResult = await pi.exec("git", ["diff", "--name-status", `${compareRef}...HEAD`], { signal: ctx.signal, timeout: 10000 });
      const commitsResult = await pi.exec("git", ["log", "--oneline", `${compareRef}..HEAD`], { signal: ctx.signal, timeout: 10000 });
      const diffResult = await pi.exec("git", ["diff", "--stat", "--patch", `${compareRef}...HEAD`], { signal: ctx.signal, timeout: 15000 });

      if (filesResult.code !== 0 || commitsResult.code !== 0 || diffResult.code !== 0) {
        ctx.ui.notify(`Could not compare against ${compareRef}. Try /pr <base-branch>.`, "error");
        return;
      }

      const chatContext = getRecentValidationContext(ctx);
      const validation = await runValidation(pi, ctx);

      ctx.ui.notify("Generating PR description with the active model...", "info");

      let draft: PullRequestDraft | null = null;
      try {
        draft = await generateDraft(ctx, template, base, branch, filesResult.stdout, commitsResult.stdout, diffResult.stdout, notes, validation, chatContext);
      } catch (error) {
        ctx.ui.notify(`Model generation failed; using fallback draft. ${error instanceof Error ? error.message : String(error)}`, "warning");
      }

      draft ??= fallbackDraft(template, branch, filesResult.stdout, commitsResult.stdout);

      const command = `!gh pr create --base ${shellQuote(base)} --head ${shellQuote(branch)} --title ${shellQuote(draft.title)} --body ${shellQuote(draft.body)}`;
      ctx.ui.setEditorText(command);
      notifyDesktop(ctx.cwd, "PR message generated.");
      ctx.ui.notify("PR command inserted into Pi chat with the generated description inline. Edit it, then press Enter to run it.", "success");
    },
  });
}
