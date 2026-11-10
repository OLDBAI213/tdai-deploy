FROM node:22-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential python3 supervisor curl git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN npm i -g pnpm@9

WORKDIR /app
COPY . /app

# ---- 依赖 ----
RUN for m in MemoryCore MemoryKnowledge MemoryProxy; do \
      cd /app/$m && npm install --no-audit --no-fund || \
      pnpm install --ignore-workspace --ignore-scripts --config.confirmModulesPurge=false; \
      npm i better-sqlite3@latest --no-audit --no-fund || true; \
    done

# ---- OpenCode 兼容层 ----
COPY docker/opencode-shim.mjs /app/opencode-shim.mjs

# ---- Knowledge 配置 ----
RUN mkdir -p /app/MemoryKnowledge/data && cat > /app/MemoryKnowledge/.env <<'EOF'
PORT=8421
API_PREFIX=/v3
LOG_LEVEL=info
KNOWLEDGE_DATA_DIR=./data
KNOWLEDGE_DB_PATH=./data/knowledge.db
LLM_MODE=custom
LLM_PROVIDER=custom
LLM_MODEL=deepseek-v4.1-flash
LLM_MAX_TOKENS=8192
LLM_TIMEOUT_MS=600000
LLM_BASE_URL=http://127.0.0.1:8899/v1
KNOWLEDGE_API_URL=http://localhost:8421
EOF

# ---- Proxy 配置 ----
RUN cat > /app/MemoryProxy/config.yaml <<'EOF'
server: { host: 0.0.0.0, port: 8096, forwardTimeoutMs: 600000 }
upstream: { url: "http://127.0.0.1:8899/v1", apiKey: "shim-local" }
log: { file: "", verbose: false, level: info, backend: console }
redis: { enabled: false }
storage: { enabled: true, backend: sqlite, ttlDays: 7, sqlite: { dbPath: "/tmp/proxy.db" } }
auth: { enabled: true, url: "http://127.0.0.1:8420", timeoutMs: 5000 }
tdai:
  enabled: true
  endpoint: "http://127.0.0.1:8420"
  apiKey: local
  serviceId: default
  memory: { enabled: true, inject: true, writeL0: true, recallL1: true, injectL2L3: true, l1Limit: 5, l2Limit: 3, timeoutMs: 5000 }
skill: { endpoint: "http://127.0.0.1:8420", serviceToken: local, serviceId: default, timeoutMs: 3000 }
knowledge: { enabled: true, endpoint: "http://127.0.0.1:8420", serviceToken: local, serviceId: default, timeoutMs: 3000 }
injection: { enabled: true, injectors: ["skill","knowledge","tdai-memory"], externalGatewayUrl: "https://tdai-proxy.onrender.com" }
extraction: { enabled: true, extractors: ["skill","tdai-memory"] }
sessionInit: { enabled: true, maxRetries: 3, skipAssetConfirm: true, headerAutoSelect: { enabled: true, teamHeader: "x-team-id", agentHeader: "x-agent-id", taskHeader: "x-task-id", onMismatch: "form" } }
skillRuntime: { allowLlmWrite: false }
opik: { enabled: false }
langfuse: { enabled: false }
clickhouse: { enabled: false }
traceArchive: { enabled: false }
rateLimit: { tpm: 1000000, qpm: 100 }
EOF

# ---- supervisord ----
COPY docker/supervisord.conf /etc/supervisor/conf.d/tdai.conf

EXPOSE 8096
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
