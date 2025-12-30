#!/bin/bash
# 文件名: /dfs/data/sbin/env.sh
# 作用: 集中管理环境变量，修改后立即生效，且防止 PATH 无限增长

# === 定义路径添加函数 (防重核心) ===
add_to_path() {
    local new_path="$1"
    # 如果 new_path 已经在 PATH 中 (头、尾或中间)，则不添加
    if [[ ":$PATH:" != *":$new_path:"* ]]; then
        export PATH="$new_path:$PATH"
    fi
}

# --- 基础路径配置 ---
# 使用函数来添加，自动去重
add_to_path "/dfs/data/bin"
add_to_path "$HOME/.local/bin"

# --- Python / UV 配置 ---
export UV_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple/"
export UV_HTTP_TIMEOUT=300

# --- HuggingFace 加速 ---
export HF_ENDPOINT="https://hf-mirror.com"
export HF_HUB_DOWNLOAD_TIMEOUT=300

# --- Git 全局配置 ---
export GIT_AUTHOR_NAME="zhangdw"
export GIT_AUTHOR_EMAIL="zhangdw.cs@gmail.com"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

# 可选：防止 git 提示 safe directory 问题（容器常见问题）
# export GIT_DISCOVERY_ACROSS_FILESYSTEM=1
# 或者直接配置 global
git config --global --replace-all safe.directory '*' 2>/dev/null
git config --global core.editor "vim"

# -- others ---
export SWANLAB_API_KEY="6NyFPQgTf8sbLDTYY48c3"
export SWANLAB_MODE=local

# --- 清理函数 (可选) ---
# 脚本执行完后取消定义函数，保持环境干净
unset -f add_to_path
