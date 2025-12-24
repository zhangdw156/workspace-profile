#!/bin/bash
# 文件名: sbin/env.sh

# --- 1. 动态获取项目根目录 ---
# 获取当前脚本所在目录 (sbin)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 获取项目根目录 (即 sbin 的上一级)
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# === 定义路径添加函数 ===
add_to_path() {
    local new_path="$1"
    if [[ ":$PATH:" != *":$new_path:"* ]]; then
        export PATH="$new_path:$PATH"
    fi
}

# --- 2. 基础路径配置 (使用动态路径) ---
# 自动添加本项目下的 bin 目录
add_to_path "$PROJECT_ROOT/bin"
add_to_path "$HOME/.local/bin"

# --- 3. Python / UV 配置 ---
export UV_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple/"
export UV_HTTP_TIMEOUT=300

# --- 4. HuggingFace 加速 ---
export HF_ENDPOINT="https://hf-mirror.com"

# --- 清理函数 ---
unset -f add_to_path
