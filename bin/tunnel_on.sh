#!/bin/bash

# --- 目录规划 (动静分离) ---
BASE_DIR="/dfs/data"
LOG_DIR="$BASE_DIR/logs"
RUN_DIR="$BASE_DIR/run"

# 确保目录存在
mkdir -p "$LOG_DIR"
mkdir -p "$RUN_DIR"

# --- 变量定义 ---
# 建议改名为 ssh_tunnel.pid 以便识别，或者保持 clash.pid 也行
PID_FILE="$RUN_DIR/ssh_tunnel.pid"
LOG_FILE="$LOG_DIR/ssh_tunnel.log"

# SSH 目标配置
REMOTE_USER="zhangdw"
REMOTE_HOST="59.110.212.190"
LOCAL_PORT="17890"
REMOTE_TARGET="127.0.0.1:7890"

# --- 1. 启动前清理 (防止重复启动) ---
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null; then
        echo "⚠️  Found running tunnel (PID: $OLD_PID), killing it..."
        kill -9 "$OLD_PID"
    fi
    rm "$PID_FILE"
fi

# 兜底清理：防止 PID 文件丢失但进程还在的情况
# 精确匹配端口转发参数，防止误杀其他 SSH 进程
STALE_PID=$(ps -ef | grep "ssh -NL $LOCAL_PORT" | grep -v grep | awk '{print $2}')
if [ -n "$STALE_PID" ]; then
    echo "🧹 Cleaning up stale tunnel process: $STALE_PID"
    kill -9 $STALE_PID
fi

# --- 2. 启动服务 ---
echo "🚀 Starting SSH Tunnel to $REMOTE_HOST..."

# 注意：这里去掉了 -f 参数，改用 nohup ... & 
# 这样我们可以通过 $! 准确获取 PID，并且把日志重定向到文件
nohup ssh -NL "$LOCAL_PORT:$REMOTE_TARGET" "$REMOTE_USER@$REMOTE_HOST" \
    > "$LOG_FILE" 2>&1 &

NEW_PID=$!

# --- 3. 保存 PID 并检查 ---
sleep 1
if ps -p "$NEW_PID" > /dev/null; then
    echo "$NEW_PID" > "$PID_FILE"
    echo "✅ Tunnel ON. PID: $NEW_PID"
    echo "📝 Logs: $LOG_FILE"
else
    echo "❌ Start failed. Check logs at $LOG_FILE"
    # 如果启动失败，可能是需要输入密码但无法交互，查看日志便知
fi
