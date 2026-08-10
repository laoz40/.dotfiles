import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";

const PASEO_MODEL = "openai-codex/gpt-5.6-luna";
const PASEO_THINKING = "high";

type StagedFile = { status: string; path: string };
type PaseoRun = { agentId?: string };
type PaseoInspect = { Status?: string };
type CommitDraftEntry = { agentId: string; content: string };

const GENERATED_PATH_PATTERNS: RegExp[] = [
  /(^|\/)dist\//,
  /(^|\/)build\//,
  /(^|\/)coverage\//,
  /(^|\/)\.next\//,
  /(^|\/)generated\//,
  /(^|\/)gen\//,
  /(^|\/)vendor\//,
  /(^|\/)node_modules\//,
  /\.min\./,
  /\.map$/,
  /(^|\/)(package-lock\.json|pnpm-lock\.yaml|yarn\.lock|bun\.lockb?)$/,
  /(^|\/)pnpm-workspace\.yaml$/,
  /(^|\/)\.eslintcache$/,
  /(^|\/)__snapshots__\//,
  /\.(snap|generated)\./,
];

function parseStagedFiles(statusOutput: string): StagedFile[] {
  return statusOutput
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const [status, ...rest] = line.split(/\s+/);
      return { status, path: rest.join(" ") };
    })
    .filter((file) => file.path.length > 0);
}

function isGeneratedPath(path: string): boolean {
  return GENERATED_PATH_PATTERNS.some((pattern) => pattern.test(path));
}

function filterFilesForCommitSignal(files: StagedFile[]): StagedFile[] {
  const filtered = files.filter((file) => !isGeneratedPath(file.path));
  return filtered.length > 0 ? filtered : files;
}

function parseJson<T>(text: string, label: string): T {
  try {
    return JSON.parse(text) as T;
  } catch {
    throw new Error(`Could not parse ${label} response: ${text || "(empty response)"}`);
  }
}

function buildPrompt(stagedSummary: string, diff: string, focusNotes: string): string {
  const focusSection = focusNotes ? `\nUser focus notes:\n${focusNotes}\n` : "";
  return `Generate one Conventional Commit draft for the staged Git changes in your working directory. Do not modify files or run git commit.${focusSection}

Return only this Markdown format, with no introduction or closing commentary:
# Commit draft

## Title
\`type(optional-scope): concise past-tense subject\`

## Description
- One past-tense bullet for each meaningful staged change.

Requirements:
- Use a Conventional Commit type: feat, fix, docs, style, refactor, perf, test, build, ci, chore, or revert.
- Keep the title under 72 characters when possible and write it in past tense.
- Cover all meaningful staged changes in the description, including distinct files or behavior changes.
- Combine bullets only when edits form one meaningful change.
- Do not invent changes; omit formatting, import ordering, generated files, lockfiles, minified assets, source maps, snapshots, and build artifacts unless they are the only staged changes.

Staged files:
${stagedSummary}

Staged diff:
${diff.slice(0, 60000)}`;
}

function extractAgentOutput(logs: string): string {
  const lines = logs.split("\n");
  const firstOutput = lines.findIndex((line) => line.startsWith("# Commit draft"));
  return firstOutput === -1 ? logs.trim() : lines.slice(firstOutput).join("\n").trim();
}

async function createDraft(pi: ExtensionAPI, ctx: ExtensionCommandContext, prompt: string): Promise<{ agentId: string; output: string }> {
  const run = await pi.exec(
    "paseo",
    [
      "run",
      "--background",
      "--provider",
      "pi",
      "--model",
      PASEO_MODEL,
      "--thinking",
      PASEO_THINKING,
      "--cwd",
      ctx.cwd,
      "--title",
      "Draft staged commit message",
      "--json",
      prompt,
    ],
    { signal: ctx.signal, timeout: 15_000 },
  );
  if (run.code !== 0) throw new Error(run.stderr || run.stdout || "Could not start the commit-draft subagent.");

  const { agentId } = parseJson<PaseoRun>(run.stdout, "Paseo run");
  if (!agentId) throw new Error("Paseo did not return a subagent ID.");

  const wait = await pi.exec("paseo", ["wait", agentId, "--timeout", "180", "--json"], {
    signal: ctx.signal,
    timeout: 190_000,
  });
  if (wait.code !== 0) throw new Error(wait.stderr || wait.stdout || "The commit-draft subagent did not finish.");

  const inspect = await pi.exec("paseo", ["inspect", agentId, "--json"], { signal: ctx.signal, timeout: 10_000 });
  if (inspect.code !== 0) throw new Error(inspect.stderr || inspect.stdout || "Could not verify the commit-draft subagent status.");
  const { Status } = parseJson<PaseoInspect>(inspect.stdout, "Paseo inspect");
  if (Status !== "idle") throw new Error(`Commit-draft subagent finished with status: ${Status ?? "unknown"}.`);

  const logs = await pi.exec("paseo", ["logs", agentId, "--tail", "50"], { signal: ctx.signal, timeout: 10_000 });
  if (logs.code !== 0) throw new Error(logs.stderr || logs.stdout || "Could not retrieve the commit-draft subagent response.");

  const output = extractAgentOutput(logs.stdout);
  if (!output) throw new Error("The commit-draft subagent returned no response.");
  return { agentId, output };
}

export default function (pi: ExtensionAPI) {
  pi.registerEntryRenderer("commit-draft", (entry) => {
    const { agentId, content } = entry.data as CommitDraftEntry;
    return new Text(`Commit draft · subagent ${agentId}\n\n${content}`, 0, 0);
  });

  pi.registerCommand("commit", {
    description: "Generate one isolated Conventional Commit draft from staged changes; optional args guide emphasis",
    handler: async (args, ctx) => {
      await ctx.waitForIdle();
      const focusNotes = args.trim();

      const status = await pi.exec("git", ["diff", "--cached", "--name-status"], { signal: ctx.signal, timeout: 5_000 });
      if (status.code !== 0) {
        ctx.ui.notify(`Could not inspect staged files:\n${status.stderr || status.stdout}`, "error");
        return;
      }

      const files = parseStagedFiles(status.stdout);
      if (files.length === 0) {
        ctx.ui.notify("No staged changes found. Stage files first, then run /commit.", "warning");
        return;
      }

      const signalFiles = filterFilesForCommitSignal(files);
      const analyzedPaths = signalFiles.map((file) => file.path);
      const diff = await pi.exec(
        "git",
        ["diff", "--cached", "--stat", "--patch", "-w", "--ignore-blank-lines", "--", ...analyzedPaths],
        { signal: ctx.signal, timeout: 10_000 },
      );
      if (diff.code !== 0) {
        ctx.ui.notify(`Could not inspect staged diff:\n${diff.stderr || diff.stdout}`, "error");
        return;
      }

      const effectiveFiles = diff.stdout.trim() ? signalFiles : files;
      const effectiveDiff = diff.stdout.trim()
        ? diff.stdout
        : (await pi.exec("git", ["diff", "--cached", "--stat", "--patch", "--", ...files.map((file) => file.path)], { signal: ctx.signal, timeout: 10_000 })).stdout;
      const stagedSummary = effectiveFiles.map((file) => `${file.status}\t${file.path}`).join("\n");

      if (signalFiles.length !== files.length) {
        ctx.ui.notify("Ignoring generated files and build artifacts for the commit-draft analysis.", "info");
      }
      ctx.ui.notify("Generating an isolated commit draft with a subagent...", "info");

      try {
        const draft = await createDraft(pi, ctx, buildPrompt(stagedSummary, effectiveDiff, focusNotes));
        pi.appendEntry("commit-draft", draft);
        ctx.ui.notify("Commit draft added outside the main model context. Review the subagent entry above.", "success");
      } catch (error) {
        ctx.ui.notify(`Commit-draft generation failed: ${error instanceof Error ? error.message : String(error)}`, "error");
      }
    },
  });
}
