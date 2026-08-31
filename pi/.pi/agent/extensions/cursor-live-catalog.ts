import type { ExtensionAPI, ProviderModelConfig } from "@earendil-works/pi-coding-agent";
import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import { pathToFileURL } from "node:url";

type CursorModel = {
  id: string;
  name: string;
  reasoning?: boolean;
  contextWindow: number;
  maxTokens: number;
};

type ProcessedModel = CursorModel & {
  supportsEffort: boolean;
  effortMap?: Record<string, string>;
};

type CursorProviderModule = {
  processModels: (raw: CursorModel[]) => ProcessedModel[];
  FALLBACK_MODELS: CursorModel[];
  supportsReasoningModelId: (id: string) => boolean;
};

type CursorProxyModule = {
  getCursorModels: (apiKey: string) => Promise<CursorModel[]>;
  getProxyPort: () => number | undefined;
};

type CursorAuthModule = {
  refreshCursorToken: (refreshToken: string) => Promise<{
    access: string;
    refresh: string;
    expires: number;
  }>;
};

const AGENT_DIR = join(homedir(), ".pi/agent");
const CURSOR_PROVIDER_ROOT = join(AGENT_DIR, "npm/node_modules/pi-cursor-provider");
const AUTH_PATH = join(AGENT_DIR, "auth.json");

function toProviderModels(
  raw: CursorModel[],
  skipDedup: boolean,
  processModels: CursorProviderModule["processModels"],
  supportsReasoningModelId: CursorProviderModule["supportsReasoningModelId"],
): ProviderModelConfig[] {
  const processed = skipDedup
    ? raw.map((model) => ({ ...model, supportsEffort: false }))
    : processModels(raw);

  return processed.map((model) => ({
    id: model.id,
    name: model.name,
    api: "openai-completions" as const,
    reasoning: supportsReasoningModelId(model.id),
    input: ["text"],
    cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
    contextWindow: model.contextWindow,
    maxTokens: model.maxTokens,
    compat: {
      supportsDeveloperRole: false,
      supportsReasoningEffort: model.supportsEffort,
      ...(model.supportsEffort && model.effortMap
        ? { reasoningEffortMap: model.effortMap }
        : {}),
    },
  }));
}

function readString(value: unknown): string | undefined {
  return typeof value === "string" && value.length > 0 ? value : undefined;
}

function readNumber(value: unknown): number | undefined {
  return typeof value === "number" && Number.isFinite(value) ? value : undefined;
}

async function loadCursorAccessToken(
  refreshCursorToken: CursorAuthModule["refreshCursorToken"],
): Promise<string | undefined> {
  let parsed: unknown;
  try {
    parsed = JSON.parse(await readFile(AUTH_PATH, "utf8"));
  } catch {
    return undefined;
  }
  if (!parsed || typeof parsed !== "object") return undefined;
  const cursor = (parsed as Record<string, unknown>).cursor;
  if (!cursor || typeof cursor !== "object") return undefined;
  const cred = cursor as Record<string, unknown>;
  const access = readString(cred.access);
  const refresh = readString(cred.refresh);
  const expires = readNumber(cred.expires);
  if (access && (expires === undefined || expires > Date.now())) {
    return access;
  }
  if (!refresh) return access;
  try {
    const refreshed = await refreshCursorToken(refresh);
    return refreshed.access;
  } catch {
    return access;
  }
}

export default async function (pi: ExtensionAPI) {
  let provider: CursorProviderModule;
  let proxy: CursorProxyModule;
  let auth: CursorAuthModule;
  try {
    const rootUrl = (file: string) => pathToFileURL(join(CURSOR_PROVIDER_ROOT, file)).href;
    provider = (await import(rootUrl("index.ts"))) as CursorProviderModule;
    proxy = (await import(rootUrl("proxy.ts"))) as CursorProxyModule;
    auth = (await import(rootUrl("auth.ts"))) as CursorAuthModule;
  } catch {
    return;
  }

  const skipDedup = Boolean(process.env.PI_CURSOR_RAW_MODELS);
  let lastCatalog = toProviderModels(
    provider.FALLBACK_MODELS,
    skipDedup,
    provider.processModels,
    provider.supportsReasoningModelId,
  );

  const token = await loadCursorAccessToken(auth.refreshCursorToken);
  if (token) {
    const discovered = await proxy.getCursorModels(token);
    if (discovered.length > 0) {
      lastCatalog = toProviderModels(
        discovered,
        skipDedup,
        provider.processModels,
        provider.supportsReasoningModelId,
      );
    }
  }

  const port = proxy.getProxyPort();
  pi.registerProvider("cursor", {
    ...(port
      ? {
          api: "openai-completions" as const,
          baseUrl: `http://127.0.0.1:${port}/v1`,
          models: lastCatalog,
        }
      : {}),
    async refreshModels(context) {
      if (!context.allowNetwork) {
        return lastCatalog;
      }

      const credential = context.credential;
      const access =
        credential?.type === "oauth" && typeof credential.access === "string"
          ? credential.access
          : undefined;
      if (!access) {
        return lastCatalog;
      }

      const discovered = await proxy.getCursorModels(access);
      if (discovered.length === 0) {
        return lastCatalog;
      }

      lastCatalog = toProviderModels(
        discovered,
        skipDedup,
        provider.processModels,
        provider.supportsReasoningModelId,
      );
      return lastCatalog;
    },
  });
}
