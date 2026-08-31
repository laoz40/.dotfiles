import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

export default function (pi: ExtensionAPI) {
  let requestFooterRender: (() => void) | undefined;

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
          const tokenText = theme.fg("success", `context ${fmtTokens(usage.contextTokens)} (${contextPct})`) + " " + theme.fg("dim", `$${usage.cost.toFixed(3)}`);
          const thinking = pi.getThinkingLevel();
          const modelName = ctx.model?.id ?? "no-model";
          const modelText = theme.fg("accent", modelName) + (thinking && thinking !== "off" ? theme.fg("warning", ` • ${thinking}`) : "");

          return [
            line(width, modelText, ""),
            lineKeepLeft(width, tokenText, theme.fg("dim", cwdText)),
          ];
        },
      };
    });
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    ctx.ui.setFooter(undefined);
    requestFooterRender = undefined;
  });

  pi.on("thinking_level_select", () => {
    requestFooterRender?.();
  });
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

function lineKeepLeft(width: number, left: string, right: string): string {
  const leftWidth = visibleWidth(left);
  const rightWidth = visibleWidth(right);
  if (leftWidth + rightWidth + 1 > width) {
    const maxRight = Math.max(0, width - leftWidth - 1);
    right = truncateToWidth(right, maxRight, "…");
  }
  const pad = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));
  return truncateToWidth(left + pad + right, width, "");
}

function fmtTokens(n: number): string {
  if (Math.abs(n) >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (Math.abs(n) >= 1_000) return `${(n / 1_000).toFixed(1)}k`;
  return `${Math.round(n)}`;
}
