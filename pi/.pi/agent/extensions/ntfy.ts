import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { basename, dirname } from "node:path";

const TOPIC_ENV = "PI_NTFY_TOPIC";
const CONFIG_PATH = `${process.env.HOME ?? "/home/leoz"}/.pi/agent/ntfy.json`;

type Config = {
  enabled: boolean;
};

let enabled = true;

function ntfyUrl(): string | undefined {
  const topic = process.env[TOPIC_ENV]?.trim();
  return topic ? `https://ntfy.sh/${topic}` : undefined;
}

async function loadConfig(): Promise<void> {
  try {
    const raw = await readFile(CONFIG_PATH, "utf8");
    const parsed = JSON.parse(raw) as Partial<Config>;
    if (typeof parsed.enabled === "boolean") enabled = parsed.enabled;
  } catch {
    enabled = true;
  }
}

async function saveConfig(): Promise<void> {
  await mkdir(dirname(CONFIG_PATH), { recursive: true });
  await writeFile(CONFIG_PATH, JSON.stringify({ enabled }, null, 2) + "\n", "utf8");
}

function sessionLabel(ctx: ExtensionContext, pi: ExtensionAPI): string {
  return pi.getSessionName()?.trim() || basename(ctx.cwd) || ctx.cwd;
}

async function sendNtfy(ctx: ExtensionContext, pi: ExtensionAPI): Promise<void> {
  const url = ntfyUrl();
  if (!url) throw new Error(`Set ${TOPIC_ENV} to enable ntfy notifications`);

  const label = sessionLabel(ctx, pi);

  const response = await fetch(url, {
    method: "POST",
    headers: {
      Title: "Pi is done",
    },
    body: `${label}: ready for input`,
  });

  if (!response.ok) {
    throw new Error(`ntfy failed: ${response.status} ${response.statusText}`);
  }
}

export default function ntfyExtension(pi: ExtensionAPI) {
  pi.on("session_start", async () => {
    await loadConfig();
  });

  pi.registerCommand("ntfy", {
    description: "Toggle ntfy phone notifications on/off",
    handler: async (_args, ctx) => {
      enabled = !enabled;
      await saveConfig();
      ctx.ui.notify(`ntfy notifications ${enabled ? "on" : "off"}`, "info");
    },
  });

  pi.on("agent_end", async (_event, ctx) => {
    if (!enabled) return;

    try {
      await sendNtfy(ctx, pi);
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      ctx.ui.notify(message, "warning");
    }
  });
}
