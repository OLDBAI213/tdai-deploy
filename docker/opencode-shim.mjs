/**
 * OpenCode Go 兼容层
 * 标准 OpenAI 请求 → 加 x-opencode-session → 走本地代理隧道 → opencode.ai/zen/go
 * 监听 127.0.0.1:8899
 */
import http from 'node:http';
import net from 'node:net';
import tls from 'node:tls';
import crypto from 'node:crypto';

const KEY = process.env.OPENCODE_GO_API_KEY || '';
const PROXY_HOST = '127.0.0.1';
const PROXY_PORT = 10889;
const UPSTREAM_HOST = 'opencode.ai';
const UPSTREAM_PREFIX = '/zen/go';
const SESSION = process.env.OC_SESSION || crypto.randomUUID();
const PORT = 8899;

if (!KEY) {
  console.error('缺少 OPENCODE_GO_API_KEY');
  process.exit(1);
}

function openTls(cb) {
  const req = http.request({
    host: PROXY_HOST,
    port: PROXY_PORT,
    method: 'CONNECT',
    path: `${UPSTREAM_HOST}:443`,
  });
  req.on('connect', (res, socket) => {
    if (res.statusCode !== 200) {
      socket.destroy();
      return cb(new Error('CONNECT failed: ' + res.statusCode));
    }
    const tlsSocket = tls.connect({ socket, servername: UPSTREAM_HOST }, () => cb(null, tlsSocket));
    tlsSocket.on('error', cb);
  });
  req.on('error', cb);
  req.end();
}

const server = http.createServer((req, res) => {
  const chunks = [];
  req.on('data', (c) => chunks.push(c));
  req.on('end', () => {
    const body = Buffer.concat(chunks);
    openTls((err, tlsSocket) => {
      if (err) {
        res.writeHead(502, { 'content-type': 'application/json' });
        return res.end(JSON.stringify({ error: String(err.message || err) }));
      }
      const headers = {
        host: UPSTREAM_HOST,
        authorization: `Bearer ${KEY}`,
        'content-type': 'application/json',
        'x-opencode-session': SESSION,
        'content-length': body.length,
      };
      const upReq = http.request(
        {
          host: UPSTREAM_HOST,
          path: UPSTREAM_PREFIX + req.url,
          method: req.method,
          headers,
          createConnection: () => tlsSocket,
        },
        (upRes) => {
          res.writeHead(upRes.statusCode, {
            'content-type': upRes.headers['content-type'] || 'application/json',
          });
          upRes.pipe(res);
        },
      );
      upReq.on('error', (e) => {
        if (!res.headersSent) res.writeHead(502, { 'content-type': 'application/json' });
        res.end(JSON.stringify({ error: String(e.message || e) }));
      });
      upReq.end(body);
    });
  });
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`opencode-shim listening on http://127.0.0.1:${PORT}/v1  session=${SESSION}`);
});
