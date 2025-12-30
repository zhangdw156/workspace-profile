#!/bin/bash

# --- 配置区 ---
# 动态获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/links.conf"
ENV_FILE="$SCRIPT_DIR/env.sh"  # <--- 指向独立的配置文件
DATA_BASE="/dfs/data/.permanent_env"
RC_FILE="$HOME/.bashrc"

echo "🔍 Reading config from $CONFIG_FILE..."

# ==========================================
# 模块 1: 软链接与数据持久化 (保持原样，逻辑很好)
# ==========================================
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: Configuration file links.conf not found!"
    return 1 2>/dev/null || exit 1
fi

grep -v '^#' "$CONFIG_FILE" | grep -v '^$' | while IFS= read -r folder; do
    folder=$(echo "$folder" | xargs)
    TARGET_PATH="$HOME/$folder"
    SOURCE_PATH="$DATA_BASE/$folder"

    if [ ! -d "$SOURCE_PATH" ]; then
        echo "📂 Creating storage: $SOURCE_PATH"
        mkdir -p "$SOURCE_PATH"
    fi

    if [ -L "$TARGET_PATH" ] && [ "$(readlink "$TARGET_PATH")" == "$SOURCE_PATH" ]; then
        echo "✅ $folder is already linked."
    else
        if [ -d "$TARGET_PATH" ] && [ ! -L "$TARGET_PATH" ]; then
            echo "📦 Migrating existing data from $TARGET_PATH..."
            cp -rn "$TARGET_PATH/." "$SOURCE_PATH/"
            rm -rf "$TARGET_PATH"
        elif [ -e "$TARGET_PATH" ] || [ -L "$TARGET_PATH" ]; then
            rm -rf "$TARGET_PATH"
        fi
        mkdir -p "$(dirname "$TARGET_PATH")"
        ln -s "$SOURCE_PATH" "$TARGET_PATH"
        echo "🚀 Linked $folder -> $SOURCE_PATH"
    fi
done

# ==========================================
# 模块 2: 权限修复
# ==========================================
if [ -d "$DATA_BASE/.ssh" ]; then
    chmod 700 "$DATA_BASE/.ssh"
    chmod 600 "$DATA_BASE/.ssh/authorized_keys" 2>/dev/null
    chmod 600 "$DATA_BASE/.ssh/id_rsa" 2>/dev/null
fi

# ==========================================
# 模块 3: 环境变量挂载 (核心优化)
# ==========================================

# 1. 确保 env.sh 存在
if [ ! -f "$ENV_FILE" ]; then
    echo "⚠️ Warning: $ENV_FILE not found! Creating a default one..."
    # 创建一个默认的 env.sh
    cat > "$ENV_FILE" <<EOF
export PATH="/dfs/data/bin:\$PATH"
export UV_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple/"
EOF
fi

# 2. 构造要写入 .bashrc 的引用命令
# 使用绝对路径，确保无论在哪里启动终端都能找到配置
LOAD_CMD="[ -f \"$ENV_FILE\" ] && source \"$ENV_FILE\""
MARKER="# --- Load Custom Env from /dfs/data ---"

# 3. 检查 .bashrc 是否已经引用了该文件
# 这里不再检查内容，而是检查是否引用了文件路径。
# 只要路径引用还在，无论你以后怎么改 env.sh，都会生效。
if ! grep -Fq "$ENV_FILE" "$RC_FILE"; then
    echo "" >> "$RC_FILE"
    echo "$MARKER" >> "$RC_FILE"
    echo "$LOAD_CMD" >> "$RC_FILE"
    echo "📝 Added external env reference to $RC_FILE"
else
    echo "✅ .bashrc is already sourcing $ENV_FILE"
fi

# ==========================================
# 模块 4: 立即生效
# ==========================================
echo "🔄 Reloading environment variables..."
source "$ENV_FILE"

echo "✨ All setups completed! Env variables are active."
