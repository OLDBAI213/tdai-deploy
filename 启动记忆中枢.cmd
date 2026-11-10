@echo off
chcp 65001 >nul
title TencentDB Agent Memory - 启动器
cd /d "%~dp0"

echo ============================================
echo   TencentDB Agent Memory 本地启动
echo   顺序: shim -> gateway -> knowledge -> panel
echo ============================================
echo.

echo [0/4] 检查代理 (127.0.0.1:10889)...
netstat -an | findstr ":10889" | findstr "LISTENING" >nul
if errorlevel 1 (
  echo     代理没开，正在启动 v2rayN...
  start "" /min "C:\Users\Administrator\Desktop\v2rayN-Core\v2rayN.exe"
  timeout /t 12 /nobreak >nul
)

echo [1/4] OpenCode 兼容层 (8899)...
start "TDAI-Shim" /min cmd /c "cd /d "%~dp0" && node opencode-shim.mjs"
timeout /t 3 /nobreak >nul

echo [2/4] Memory Gateway (8420)...
start "TDAI-Gateway" /min cmd /c "cd /d "%~dp0MemoryCore" && node node_modules\tsx\dist\cli.mjs src\gateway\server.ts"
timeout -t 8 /nobreak >nul

echo [3/4] Knowledge Service (8421)...
start "TDAI-Knowledge" /min cmd /c "cd /d "%~dp0MemoryKnowledge" && set LLM_API_KEY=shim-local&& set LLM_BASE_URL=http://127.0.0.1:8899/v1&& set LLM_MODEL=deepseek-v4.1-flash&& node node_modules\tsx\dist\cli.mjs src\server.ts"
timeout /t 8 /nobreak >nul

echo [4/4] Panel (8123)...
start "TDAI-Panel" /min cmd /c "cd /d "%~dp0MemoryPanel" && node node_modules\tsx\dist\cli.mjs src\index.ts"
timeout /t 8 /nobreak >nul

echo.
echo ============================================
echo   面板: http://127.0.0.1:8123
echo   登录 User Key:
type ".admin-key"
echo ============================================
start "" http://127.0.0.1:8123
echo 关闭四个黑窗口即停止全部服务。
pause
