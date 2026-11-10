#!/usr/bin/env bash
# ============================================================
# TencentDB Agent Memory —— 一键部署到一台干净的 Ubuntu 22/24
#
# 用法（在新服务器上）：
#   curl -O <本文件>  或者 scp 上去
#   bash deploy-tdai.sh
#
# 前置：一台有公网 IP 的 Ubuntu，能访问 github / npm / opencode.ai
#       已放好 ~/.oc_key（OpenCode Go 的 key，一行，无换行）
# ============================================================
set -euo pipefail

echo "=== [1/6] 系统依赖 ==="
sudo apt-get update -qq
sudo apt-get install -y -qq curl git build-essential python3

echo "=== [2/6] Node 22 ==="
if ! node -v 2>/dev/null | grep -q '^v22'; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - >/dev/null 2>&1
  sudo apt-get install -y -qq nodejs
fi
node -v
npm i -g pnpm@9 >/dev/null 2>&1 || true

echo "=== [3/6] 拉仓库 ==="
cd ~ && rm -rf tdai && git clone --depth 1 https://github.com/TencentCloud/TencentDB-Agent-Memory.git tdai
cd ~/tdai

echo "=== [4/6] 装依赖 ==="
for m in MemoryCore MemoryKnowledge MemoryProxy; do
  echo "  → $m"
  (cd $m && npm install --no-audit --no-fund >/dev/null 2>&1 || pnpm install --ignore-workspace --ignore-scripts --config.confirmModulesPurge=false >/dev/null 2>&1)
  (cd $m && npm i better-sqlite3@latest --no-audit --no-fund >/dev/null 2>&1 || true)
done

echo "=== [5/6] 写配置 ==="
# OpenCode 兼容层
cat > ~/tdai/opencode-shim.mjs <<'EOF'
import http from 'node:http';
import https from 'node:https';
import crypto from 'node:crypto';
const KEY = process.env.OPENCODE_GO_API_KEY || '';
const HOST = 'opencode.ai', PREFIX = '/zen/go';
const SESSION = process.env.OC_SESSION || crypto.randomUUID();
if (!KEY) { console.error('no key'); process.exit(1); }
http.createServer((req, res) => {
  const chunks = [];
  req.on('data', c => chunks.push(c));
  req.on('end', () => {
    const body = Buffer.concat(chunks);
    const upReq = https.request({
      host: HOST, path: PREFIX + req.url, method: req.method,
      headers: { host: HOST, authorization: `Bearer ${KEY}`, 'content-type': 'application/json',
                 'x-opencode-session': SESSION, 'content-length': body.length },
    }, upRes => {
      res.writeHead(upRes.statusCode, { 'content-type': upRes.headers['content-type'] || 'application/json' });
      upRes.pipe(res);
    });
    upReq.on('error', e => { if (!res.headersSent) res.writeHead(502); res.end(JSON.stringify({ error: String(e.message || e) })); });
    upReq.end(body);
  });
}).listen(8899, '127.0.0.1', () => console.log('shim :8899'));
EOF

# Knowledge
cat > ~/tdai/MemoryKnowledge/.env <<'EOF'
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

# Proxy
cat > ~/tdai/MemoryProxy/config.yaml <<'EOF'
server: { host: 0.0.0.0, port: 8096, forwardTimeoutMs: 600000 }
upstream: { url: "http://127.0.0.1:8899/v1", apiKey: "shim-local" }
log: { file: logs, verbose: false, level: info, backend: console }
redis: { enabled: false }
storage: { enabled: true, backend: sqlite, ttlDays: 7, sqlite: { dbPath: "" } }
auth: { enabled: true, url: "http://127.0.0.1:8420", timeoutMs: 5000 }
tdai:
  enabled: true
  endpoint: "http://127.0.0.1:8420"
  apiKey: local
  serviceId: default
  memory: { enabled: true, inject: true, writeL0: true, recallL1: true, injectL2L3: true, l1Limit: 5, l2Limit: 3, timeoutMs: 5000 }
skill: { endpoint: "http://127.0.0.1:8420", serviceToken: local, serviceId: default, timeoutMs: 3000 }
knowledge: { enabled: true, endpoint: "http://127.0.0.1:8420", serviceToken: local, serviceId: default, timeoutMs: 3000 }
injection: { enabled: true, injectors: ["skill","knowledge","tdai-memory"], externalGatewayUrl: "http://127.0.0.1:8096" }
extraction: { enabled: true, extractors: ["skill","tdai-memory"] }
sessionInit: { enabled: true, maxRetries: 3, skipAssetConfirm: true, headerAutoSelect: { enabled: true, teamHeader: "x-team-id", agentHeader: "x-agent-id", taskHeader: "x-task-id", onMismatch: "form" } }
skillRuntime: { allowLlmWrite: false }
opik: { enabled: false }
langfuse: { enabled: false }
clickhouse: { enabled: false }
traceArchive: { enabled: false }
rateLimit: { tpm: 1000000, qpm: 100 }
EOF

echo "=== [6/6] 起服务 ==="
cd ~/tdai && OPENCODE_GO_API_KEY="$(cat ~/.oc_key)" setsid nohup node opencode-shim.mjs > shim.log 2>&1 < /dev/null &
sleep 3
cd ~/tdai/MemoryCore && TDAI_LLM_BASE_URL=http://127.0.0.1:8899/v1 TDAI_LLM_API_KEY=shim TDAI_LLM_MODEL=deepseek-v4.1-flash \
  setsid nohup npx tsx src/gateway/server.ts > ../gw.log 2>&1 < /dev/null &
sleep 12
cd ~/tdai/MemoryKnowledge && LLM_API_KEY=shim setsid nohup npx tsx src/server.ts > ../ks.log 2>&1 < /dev/null &
sleep 15
cd ~/tdai/MemoryProxy && setsid nohup npx tsx src/index.ts --config config.yaml > ../proxy.log 2>&1 < /dev/null &
sleep 12

echo
echo "========== 自检 =========="
for p in 8899 8420 8421 8096; do
  printf "%-6s : %s\n" $p "$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 http://127.0.0.1:$p/health 2>/dev/null)"
done

echo
echo "初始化管理员（只需一次）："
curl -s -X POST http://127.0.0.1:8420/v3/internal/meta/user/init-admin \
  -H 'content-type: application/json' -H 'x-tdai-service-id: default' \
  -d '{"username":"admin"}' | tee ~/.admin-key.json
echo
echo "公网访问地址："
echo "  http://$(curl -s --max-time 5 ifconfig.me):8096"
echo
echo "重启全部服务：bash ~/tdai/restart.sh"
