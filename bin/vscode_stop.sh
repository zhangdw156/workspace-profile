#!/bin/bash

# --- 目录规划 ---
BASE_DIR="/dfs/data"
RUN_DIR="$BASE_DIR/run"
PID_FILE="$RUN_DIR/vscode.pid"

echo "🛑 Stopping VSCode Server..."

# --- 1. 优先尝试通过 PID 文件停止 ---
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null; then
        kill -9 "$PID"
        echo "✅ Stopped VSCode (PID: $PID)."
    else
        echo "ℹ️  Process $PID not found."
    fi
    rm "$PID_FILE"
else
    echo "⚠️  PID file not found at $PID_FILE"
fi

# --- 2. 兜底逻辑 ---
ALT_PID=$(ps -ef | grep "code-server" | grep "bind-addr=0.0.0.0:8080" | grep -v grep | awk '{print $2}')

if [ -n "$ALT_PID" ]; then
    echo "$ALT_PID" | xargs kill -9
    echo "🧹 Cleaned up stale processes: $ALT_PID"
else
    echo "ℹ️  No running instance found."
fi
