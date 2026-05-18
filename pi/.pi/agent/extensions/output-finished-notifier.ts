import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { existsSync } from "node:fs";
import { spawn } from "node:child_process";
import { basename } from "node:path";

type MessageLike = {
  role?: string;
  stopReason?: string;
  content?: Array<{ type?: string; text?: string }>;
};

const SOUND_FILE = "/usr/share/sounds/freedesktop/stereo/message-new-instant.oga";
const SOUND_VOLUME_MULTIPLIER = 1.5;
const CANBERRA_BASE_VOLUME_DB = 12.0;
const PW_PLAY_BASE_VOLUME = 1.0;
const PAPLAY_BASE_VOLUME = 65536 * 4;
const MPV_BASE_VOLUME = 100;

function runDetached(command: string, args: string[]): void {
  const child = spawn(command, args, {
    detached: true,
    stdio: "ignore",
  });
  child.unref();
}

function soundCommand(): string | null {
  if (!existsSync(SOUND_FILE)) {
    return `true`;
  }

  return [
    `if command -v canberra-gtk-play >/dev/null 2>&1; then`,
    `  canberra-gtk-play --file=${JSON.stringify(SOUND_FILE)} --volume=${(CANBERRA_BASE_VOLUME_DB * SOUND_VOLUME_MULTIPLIER).toFixed(1)} >/dev/null 2>&1`,
    `elif command -v pw-play >/dev/null 2>&1; then`,
    `  pw-play --volume=${(PW_PLAY_BASE_VOLUME * SOUND_VOLUME_MULTIPLIER).toFixed(1)} ${JSON.stringify(SOUND_FILE)} >/dev/null 2>&1`,
    `elif command -v paplay >/dev/null 2>&1; then`,
    `  paplay --volume=${Math.round(PAPLAY_BASE_VOLUME * SOUND_VOLUME_MULTIPLIER)} ${JSON.stringify(SOUND_FILE)} >/dev/null 2>&1`,
    `elif command -v mpv >/dev/null 2>&1; then`,
    `  mpv --no-video --really-quiet --volume=${Math.round(MPV_BASE_VOLUME * SOUND_VOLUME_MULTIPLIER)} ${JSON.stringify(SOUND_FILE)} >/dev/null 2>&1`,
    `elif command -v aplay >/dev/null 2>&1; then`,
    `  aplay ${JSON.stringify(SOUND_FILE)} >/dev/null 2>&1`,
    `else`,
    `  true`,
    `fi`,
  ].join("\n");
}

function notify(title: string, body: string): void {
  if (process.platform !== "linux") return;
  runDetached("notify-send", [title, body]);
}

function notificationTitle(cwd: string, sessionName?: string): string {
  const source = sessionName?.trim() || basename(cwd) || cwd;
  return `Pi: ${source}`;
}

function playSound(): void {
  runDetached("bash", ["-lc", soundCommand() ?? "true"]);
}

let lastUserInputNotificationAt = 0;

function notifyUserInputNeeded(ctx: ExtensionContext, pi: ExtensionAPI, source: string): void {
  const now = Date.now();
  if (now - lastUserInputNotificationAt < 1000) return;
  lastUserInputNotificationAt = now;

  notify(notificationTitle(ctx.cwd, pi.getSessionName()), "Your input is needed.");
  playSound();
  ctx.ui.notify(`${source} is waiting for your response.`, "info");
}

const patchedUis = new WeakSet<object>();

function patchUiPrompts(ctx: ExtensionContext, pi: ExtensionAPI): void {
  const ui = ctx.ui as Record<string, unknown>;
  if (patchedUis.has(ui)) return;
  patchedUis.add(ui);

  for (const method of ["select", "confirm", "input", "editor"] as const) {
    const original = ui[method];
    if (typeof original !== "function") continue;

    ui[method] = function wrappedUserPrompt(this: unknown, ...args: unknown[]) {
      notifyUserInputNeeded(ctx, pi, `ctx.ui.${method}`);
      return original.apply(this, args);
    };
  }
}

function hasFinalTextAssistant(messages: MessageLike[] | undefined): boolean {
  if (!messages?.length) return false;

  for (let index = messages.length - 1; index >= 0; index -= 1) {
    const message = messages[index];
    if (message.role !== "assistant") continue;
    if (message.stopReason === "toolUse" || message.stopReason === "aborted" || message.stopReason === "error") {
      return false;
    }

    const hasText = message.content?.some((part) => part.type === "text" && typeof part.text === "string" && part.text.trim().length > 0);
    const hasToolCall = message.content?.some((part) => part.type === "toolCall");
    return Boolean(hasText && !hasToolCall);
  }

  return false;
}

const USER_PROMPT_TOOL_NAMES = new Set([
  "ask_user_question",
  "ask_user",
  "ask_user_prompt",
  "ask_user_tool",
  "rpiv_ask_user_question",
  "rpiv_ask_user",
  "rpiv_ask_user_prompt",
]);

const USER_PROMPT_TOOL_PATTERNS = [
  /(^|[_.:-])ask[_.:-]?user($|[_.:-])/i,
  /(^|[_.:-])user[_.:-]?prompt($|[_.:-])/i,
  /(^|[_.:-])user[_.:-]?question($|[_.:-])/i,
  /(^|[_.:-])request[_.:-]?user[_.:-]?input($|[_.:-])/i,
  /(^|[_.:-])human[_.:-]?input($|[_.:-])/i,
];

function isUserPromptTool(toolName: string): boolean {
  if (USER_PROMPT_TOOL_NAMES.has(toolName)) return true;

  const normalized = toolName
    .replace(/^functions[_.:-]/i, "")
    .replace(/^tools[_.:-]/i, "")
    .replace(/([a-z0-9])([A-Z])/g, "$1_$2");

  return USER_PROMPT_TOOL_PATTERNS.some((pattern) => pattern.test(normalized));
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    patchUiPrompts(ctx, pi);
  });

  pi.on("input", async (_event, ctx) => {
    patchUiPrompts(ctx, pi);
  });

  pi.on("tool_execution_start", async (event, ctx) => {
    patchUiPrompts(ctx, pi);
    if (!isUserPromptTool(event.toolName)) return;

    notifyUserInputNeeded(ctx, pi, event.toolName);
  });

  pi.on("agent_end", async (event, ctx) => {
    if (!hasFinalTextAssistant(event.messages as MessageLike[] | undefined)) return;

    notify(notificationTitle(ctx.cwd, pi.getSessionName()), "The final assistant response is ready.");
    playSound();

    ctx.ui.notify("pi finished responding.", "success");
  });
}
