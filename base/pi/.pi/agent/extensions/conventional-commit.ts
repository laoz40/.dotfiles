import { complete, type Message } from "@mariozechner/pi-ai";
import type { ExtensionAPI, ExtensionCommandContext } from "@mariozechner/pi-coding-agent";

const SYSTEM_PROMPT = `You generate Conventional Commit messages from staged git diffs.
Return only valid JSON in this shape:
{
  "candidates": [
    { "header": "type(optional-scope): concise subject", "bullets": ["Major change", "Another major change"] }
  ]
}
Rules:
- Generate 3 to 5 candidates.
- Use Conventional Commit types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert.
- Keep headers under 72 characters when possible.
- Write commit headers in past tense, e.g. "feat(commit): added model-generated messages" not "feat(commit): add model-generated messages".
- Bullets describe major changes, not tiny line-by-line edits.
- Write bullet descriptions in past tense, e.g. "Updated config loading" not "Update config loading".
- Do not include markdown fences or commentary.`;

type StagedFile = { status: string; path: string };
type Candidate = { header: string; bullets: string[] };

const TYPE_BY_PATH: Array<[RegExp, string]> = [
  [/^(test|tests|__tests__|.*\.(test|spec)\.)/, "test"],
  [/^(docs?|README|CHANGELOG|.*\.md$)/i, "docs"],
  [/^(package-lock\.json|pnpm-lock\.yaml|yarn\.lock|bun\.lockb?)$/, "chore"],
  [/^(\.github|ci|\.gitlab-ci|Dockerfile|docker-compose)/, "ci"],
  [/^(styles?|css|.*\.(css|scss|sass|less)$)/, "style"],
];

function shellQuote(value: string): string {
  return `'${value.replace(/'/g, `'"'"'`)}'`;
}

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

function scopeFromPath(path: string): string | undefined {
  const parts = path.split("/").filter(Boolean);
  if (parts.length === 0) return undefined;
  if (["src", "app", "lib", "packages", "apps", "components"].includes(parts[0]) && parts[1]) {
    return parts[1].replace(/\.[^.]+$/, "");
  }
  return parts[0].replace(/^\./, "").replace(/\.[^.]+$/, "");
}

function inferPrimaryType(files: StagedFile[], diff: string): string {
  const paths = files.map((file) => file.path);
  if (/^\+\s*(export\s+)?(async\s+)?function\s|^\+\s*(const|let|var)\s+\w+\s*=|^\+\s*class\s/m.test(diff)) return "feat";
  if (/^[-+]\s*fix|bug|error|throw|catch|regression/im.test(diff)) return "fix";
  for (const [pattern, type] of TYPE_BY_PATH) if (paths.some((path) => pattern.test(path))) return type;
  if (files.every((file) => file.status.startsWith("D"))) return "chore";
  return "chore";
}

function summarizeStatus(files: StagedFile[]): string[] {
  const added = files.filter((file) => file.status.startsWith("A")).map((file) => file.path);
  const modified = files.filter((file) => file.status.startsWith("M")).map((file) => file.path);
  const deleted = files.filter((file) => file.status.startsWith("D")).map((file) => file.path);
  const renamed = files.filter((file) => file.status.startsWith("R")).map((file) => file.path);
  const bullets: string[] = [];
  if (added.length) bullets.push(`Added ${formatPaths(added)}`);
  if (modified.length) bullets.push(`Updated ${formatPaths(modified)}`);
  if (deleted.length) bullets.push(`Removed ${formatPaths(deleted)}`);
  if (renamed.length) bullets.push(`Renamed ${formatPaths(renamed)}`);
  return bullets;
}

function formatPaths(paths: string[]): string {
  if (paths.length <= 3) return paths.join(", ");
  return `${paths.slice(0, 3).join(", ")} and ${paths.length - 3} more`;
}

function extractDiffBullets(diff: string): string[] {
  const files = [...diff.matchAll(/^diff --git a\/(.*?) b\/(.*?)$/gm)].map((match) => match[2]);
  const bullets: string[] = [];
  for (const file of files.slice(0, 5)) {
    const fileBlock = diff.split(` b/${file}`)[1] ?? "";
    const additions = (fileBlock.match(/^\+(?!\+\+)/gm) ?? []).length;
    const deletions = (fileBlock.match(/^-(?!--)/gm) ?? []).length;
    if (additions || deletions) bullets.push(`Changed ${file} (${additions} additions, ${deletions} deletions)`);
  }
  return bullets;
}

function buildHeuristicCandidates(files: StagedFile[], diff: string): Candidate[] {
  const type = inferPrimaryType(files, diff);
  const scopes = [...new Set(files.map((file) => scopeFromPath(file.path)).filter(Boolean))] as string[];
  const scope = scopes.length === 1 ? scopes[0] : scopes.length > 1 ? "repo" : undefined;
  const typeScope = scope ? `${type}(${scope})` : type;
  const statusBullets = summarizeStatus(files);
  const diffBullets = extractDiffBullets(diff);
  const bullets = [...statusBullets, ...diffBullets].slice(0, 6);
  const noun = scope && scope !== "repo" ? scope : files.length === 1 ? files[0].path.split("/").pop()?.replace(/\.[^.]+$/, "") : "staged changes";

  const subjects = [
    `${typeScope}: updated ${noun}`,
    `${typeScope}: refined ${noun}`,
    `${typeScope}: prepared ${noun} changes`,
  ];

  const alternates = ["feat", "fix", "chore", "refactor", "docs", "test"].filter((candidate) => candidate !== type).slice(0, 2);
  for (const alternate of alternates) subjects.push(`${scope ? `${alternate}(${scope})` : alternate}: updated ${noun}`);

  return subjects.map((header) => ({ header, bullets }));
}

function parseModelCandidates(text: string): Candidate[] {
  const jsonText = text.replace(/^```(?:json)?\s*/i, "").replace(/```$/i, "").trim();
  const parsed = JSON.parse(jsonText) as { candidates?: Candidate[] };
  return (parsed.candidates ?? [])
    .filter((candidate) => typeof candidate.header === "string" && Array.isArray(candidate.bullets))
    .map((candidate) => ({
      header: candidate.header.trim(),
      bullets: candidate.bullets.filter((bullet) => typeof bullet === "string").map((bullet) => bullet.trim()).filter(Boolean).slice(0, 6),
    }))
    .filter((candidate) => candidate.header.length > 0)
    .slice(0, 5);
}

async function buildModelCandidates(ctx: ExtensionCommandContext, stagedSummary: string, diff: string): Promise<Candidate[]> {
  if (!ctx.model) throw new Error("No active model selected");

  const auth = await ctx.modelRegistry.getApiKeyAndHeaders(ctx.model);
  if (!auth.ok || !auth.apiKey) throw new Error(auth.ok ? `No API key for ${ctx.model.provider}` : auth.error);

  const userMessage: Message = {
    role: "user",
    content: [{ type: "text", text: `Staged files:\n${stagedSummary}\n\nStaged diff:\n${diff.slice(0, 60000)}` }],
    timestamp: Date.now(),
  };

  const response = await complete(
    ctx.model,
    { systemPrompt: SYSTEM_PROMPT, messages: [userMessage] },
    { apiKey: auth.apiKey, headers: auth.headers, signal: ctx.signal },
  );

  if (response.stopReason === "aborted") return [];

  const text = response.content
    .filter((part): part is { type: "text"; text: string } => part.type === "text")
    .map((part) => part.text)
    .join("\n");

  return parseModelCandidates(text);
}

export default function (pi: ExtensionAPI) {
  const handler = async (_args: string, ctx: ExtensionCommandContext) => {
      await ctx.waitForIdle();

      const status = await pi.exec("git", ["diff", "--cached", "--name-status"], { signal: ctx.signal, timeout: 5000 });
      if (status.code !== 0) {
        ctx.ui.notify(`Could not inspect staged files:\n${status.stderr || status.stdout}`, "error");
        return;
      }

      const files = parseStagedFiles(status.stdout);
      if (files.length === 0) {
        ctx.ui.notify("No staged changes found. Stage files first, then run /commitmsg.", "warning");
        return;
      }

      const diff = await pi.exec("git", ["diff", "--cached", "--stat", "--patch"], { signal: ctx.signal, timeout: 10000 });
      ctx.ui.notify("Generating commit messages with the active model...", "info");

      let candidates: Candidate[];
      try {
        candidates = await buildModelCandidates(ctx, status.stdout, diff.stdout || "");
      } catch (error) {
        ctx.ui.notify(`Model generation failed; using local fallback. ${error instanceof Error ? error.message : String(error)}`, "warning");
        candidates = buildHeuristicCandidates(files, diff.stdout || "");
      }

      if (candidates.length === 0) candidates = buildHeuristicCandidates(files, diff.stdout || "");
      const labels = candidates.map((candidate) => `${candidate.header}\n${candidate.bullets.map((bullet) => `  • ${bullet}`).join("\n")}`);
      const selected = await ctx.ui.select("Choose a conventional commit message", labels);
      if (!selected) return;

      const candidate = candidates[labels.indexOf(selected)];
      const body = candidate.bullets.map((bullet) => `- ${bullet}`).join("\n");
      const command = `!git commit -m ${shellQuote(candidate.header)}${body ? ` -m ${shellQuote(body)}` : ""}`;

      ctx.ui.setEditorText(command);
      ctx.ui.notify("Commit command inserted into Pi chat. Review, then press Enter to run it.", "success");
    };

  pi.registerCommand("commit", {
    description: "Pick a conventional commit message from staged changes",
    handler,
  });
}
