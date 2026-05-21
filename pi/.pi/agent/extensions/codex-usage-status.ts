import { spawn } from "node:child_process";
import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

type LimitWindow = {
  usedPercent?: number;
  windowDurationMins?: number | null;
  resetsAt?: number | null;
};

type Usage = {
  fiveHour?: LimitWindow | null;
  weekly?: LimitWindow | null;
  error?: string;
};

const REFRESH_MS = 60_000;

export default function (pi: ExtensionAPI) {
  let timer: NodeJS.Timeout | undefined;
  let requestFooterRender: (() => void) | undefined;
  let last: Usage = {};

  async function update(ctx: ExtensionContext) {
    last = await fetchUsage();
    requestFooterRender?.();
  }

  pi.on("session_start", async (_event, ctx) => {
    ctx.ui.setFooter((tui, theme, footerData) => {
      requestFooterRender = () => tui.requestRender();
      const unsubscribe = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: unsubscribe,
        invalidate() {},
        render(width: number): string[] {
          const branch = footerData.getGitBranch();
          const cwd = ctx.cwd.replace(process.env.HOME ?? "", "~");
          const cwdText = branch ? `${cwd} (${branch})` : cwd;
          const usage = getTokenUsage(ctx);
          const contextWindow = (ctx.model as any)?.contextWindow as number | undefined;
          const contextPct = contextWindow ? `${Math.round((usage.contextTokens / contextWindow) * 100)}%/${fmtTokens(contextWindow)}` : "?";
          const tokenText = `↑${fmtTokens(usage.input)} ↓${fmtTokens(usage.output)} context ${fmtTokens(usage.contextTokens)} (${contextPct}) $${usage.cost.toFixed(3)}`;
          const thinking = pi.getThinkingLevel();
          const modelText = `${ctx.model?.id ?? "no-model"}${thinking && thinking !== "off" ? ` • ${thinking}` : ""}`;
          const codexText = plainStatus(last);

          return [
            line(width, theme.fg("dim", modelText), theme.fg(last.error ? "warning" : "dim", codexText)),
            line(width, theme.fg("dim", tokenText), theme.fg("dim", cwdText)),
          ];
        },
      };
    });

    await update(ctx);
    timer = setInterval(() => void update(ctx), REFRESH_MS);
    timer.unref?.();
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    if (timer) clearInterval(timer);
    timer = undefined;
    ctx.ui.setFooter(undefined);
    requestFooterRender = undefined;
  });

  pi.on("thinking_level_select", () => {
    requestFooterRender?.();
  });

  pi.registerCommand("codex-usage", {
    description: "Refresh Codex 5h/weekly usage in the status bar",
    handler: async (_args, ctx) => {
      await update(ctx);
      ctx.ui.notify(`Codex usage: ${plainStatus(last)}`, last.error ? "warning" : "info");
    },
  });
}

async function fetchUsage(): Promise<Usage> {
  try {
    const raw = await callCodexAppServer("account/rateLimits/read");
    const snapshot = raw?.rateLimitsByLimitId?.codex ?? raw?.rateLimits;
    if (!snapshot) return { error: "no snapshot" };
    return { fiveHour: snapshot.primary, weekly: snapshot.secondary };
  } catch (error) {
    return { error: error instanceof Error ? error.message : "failed" };
  }
}

function callCodexAppServer(method: string): Promise<any> {
  return new Promise((resolve, reject) => {
    const child = spawn("codex", ["app-server", "--listen", "stdio://"], {
      stdio: ["pipe", "pipe", "pipe"],
    });

    let stdout = "";
    let stderr = "";
    const timeout = setTimeout(() => {
      child.kill();
      reject(new Error("timeout"));
    }, 15_000);

    child.stdout.setEncoding("utf8");
    child.stderr.setEncoding("utf8");
    child.stdout.on("data", (chunk) => {
      stdout += chunk;
      for (const line of stdout.split("\n")) {
        if (!line.trim()) continue;
        try {
          const msg = JSON.parse(line);
          if (msg.id === 2) {
            clearTimeout(timeout);
            child.kill();
            if (msg.error) reject(new Error(msg.error.message ?? JSON.stringify(msg.error)));
            else resolve(msg.result);
          }
        } catch {
          // Wait for complete JSONL records.
        }
      }
    });
    child.stderr.on("data", (chunk) => (stderr += chunk));
    child.on("error", (error) => {
      clearTimeout(timeout);
      reject(error);
    });
    child.on("exit", (code) => {
      if (code && code !== 0) {
        clearTimeout(timeout);
        reject(new Error(stderr.trim() || `codex exited ${code}`));
      }
    });

    child.stdin.write(JSON.stringify({ id: 1, method: "initialize", params: { clientInfo: { name: "pi-codex-usage", version: "1" }, capabilities: {} } }) + "\n");
    child.stdin.write(JSON.stringify({ id: 2, method, params: null }) + "\n");
  });
}

function plainStatus(usage: Usage): string {
  if (usage.error) return usage.error;
  return `5h: ${formatWindow(usage.fiveHour)} · week: ${formatWindow(usage.weekly)}`;
}

function formatWindow(w?: LimitWindow | null): string {
  if (!w) return "?";
  const pct = typeof w.usedPercent === "number" ? `${Math.max(0, 100 - Math.round(w.usedPercent))}%` : "?";
  const reset = formatReset(w.resetsAt);
  return reset ? `${pct} (${reset})` : pct;
}

function formatReset(epochSeconds?: number | null): string {
  if (!epochSeconds) return "";
  const ms = epochSeconds * 1000 - Date.now();
  if (ms <= 0) return "now";
  const mins = Math.ceil(ms / 60_000);
  if (mins < 60) return `${mins}m`;
  const hours = Math.floor(mins / 60);
  const remMins = mins % 60;
  if (hours < 48) return remMins ? `${hours}h${remMins}m` : `${hours}h`;
  return `${Math.ceil(hours / 24)}d`;
}

function getTokenUsage(ctx: ExtensionContext) {
  let input = 0;
  let output = 0;
  let cost = 0;
  for (const entry of ctx.sessionManager.getBranch()) {
    if (entry.type === "message" && entry.message.role === "assistant") {
      const message = entry.message as AssistantMessage;
      input += message.usage?.input ?? 0;
      output += message.usage?.output ?? 0;
      cost += message.usage?.cost?.total ?? 0;
    }
  }
  return {
    input,
    output,
    cost,
    contextTokens: ctx.getContextUsage()?.tokens ?? input + output,
  };
}

function line(width: number, left: string, right: string): string {
  const leftWidth = visibleWidth(left);
  const rightWidth = visibleWidth(right);
  if (leftWidth + rightWidth + 1 > width) {
    const maxLeft = Math.max(0, width - rightWidth - 1);
    left = truncateToWidth(left, maxLeft, "…");
  }
  const pad = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));
  return truncateToWidth(left + pad + right, width, "");
}

function statusesLine(width: number, theme: any, statuses: ReadonlyMap<string, string>): string {
  const text = [...statuses.entries()]
    .filter(([key]) => key !== "codex-usage" && !key.toLowerCase().includes("thinking"))
    .map(([, value]) => value)
    .join(" · ");
  return text ? truncateToWidth(theme.fg("dim", text), width, "…") : "";
}

function fmtTokens(n: number): string {
  if (Math.abs(n) >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (Math.abs(n) >= 1_000) return `${(n / 1_000).toFixed(1)}k`;
  return `${Math.round(n)}`;
}
