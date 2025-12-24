#!/bin/bash

# --- 目录规划 (动静分离) ---
BASE_DIR="/dfs/data"
BIN_DIR="$BASE_DIR/bin"
LOG_DIR="$BASE_DIR/logs"
RUN_DIR="$BASE_DIR/run"

# 确保目录存在
mkdir -p "$LOG_DIR"
mkdir -p "$RUN_DIR"

# --- 变量定义 ---
PID_FILE="$RUN_DIR/vscode.pid"  # PID 去 run 目录
LOG_FILE="$LOG_DIR/vscode.log"  # Log 去 logs 目录
BIN_PATH="/dfs/share-read-only/code-server/bin/code-server"

# 固定密码
export PASSWORD="ds123456"

# --- 1. 启动前清理 ---
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null; then
        echo "⚠️  Found running instance (PID: $OLD_PID), killing it..."
        kill -9 "$OLD_PID"
    fi
    rm "$PID_FILE"
fi

STALE_PID=$(ps -ef | grep "code-server" | grep "bind-addr=0.0.0.0:8080" | grep -v grep | awk '{print $2}')
if [ -n "$STALE_PID" ]; then
    echo "🧹 Cleaning up stale process: $STALE_PID"
    kill -9 $STALE_PID
fi

# --- 2. 启动服务 ---
echo "🚀 Starting VSCode Server..."

nohup "$BIN_PATH" \
    --auth=password \
    --bind-addr=0.0.0.0:8080 \
    --user-data-dir=/dfs/data/ \
    --extensions-dir=/dfs/data/ \
    > "$LOG_FILE" 2>&1 &

NEW_PID=$!

sleep 1
if ps -p "$NEW_PID" > /dev/null; then
    echo "$NEW_PID" > "$PID_FILE"
    echo "✅ VSCode Started. PID: $NEW_PID"
    echo "📂 Logs: $LOG_FILE"
else
    echo "❌ Start failed. Check logs at $LOG_FILE"
fi
