#!/bin/bash

# --- 目录规划 ---
BASE_DIR="/dfs/data"
RUN_DIR="$BASE_DIR/run"
PID_FILE="$RUN_DIR/ssh_tunnel.pid"

# 定义端口以便兜底搜索
LOCAL_PORT="17890"

echo "🛑 Stopping SSH Tunnel..."

# --- 1. 优先尝试通过 PID 文件停止 ---
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    
    if ps -p "$PID" > /dev/null; then
        kill -9 "$PID"
        echo "✅ Stopped Tunnel (PID: $PID)."
    else
        echo "ℹ️  Process $PID not found in system."
    fi
    
    rm "$PID_FILE"
else
    echo "⚠️  PID file not found at $PID_FILE"
fi

# --- 2. 兜底逻辑：通过端口参数搜索 ---
# 搜索包含 ssh -NL 17890 的进程
ALT_PID=$(ps -ef | grep "ssh -NL $LOCAL_PORT" | grep -v grep | awk '{print $2}')

if [ -n "$ALT_PID" ]; then
    echo "$ALT_PID" | xargs kill -9
    echo "🧹 Cleaned up stale tunnel processes: $ALT_PID"
else
    echo "ℹ️  No running tunnel found."
fi
