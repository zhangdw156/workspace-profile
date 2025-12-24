#!/bin/bash
# 文件名: sbin/setup.sh

# --- 配置区 (动态化) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

CONFIG_FILE="$SCRIPT_DIR/links.conf"
ENV_FILE="$SCRIPT_DIR/env.sh"

# 关键：持久化目录改为项目根目录下的 .permanent_env
DATA_BASE="$PROJECT_ROOT/.permanent_env"
RC_FILE="$HOME/.bashrc"

echo "🔍 Init setup at: $PROJECT_ROOT"

# --- 模块 1: 软链接与数据持久化 ---
# (这部分逻辑保持不变，只需确保 DATA_BASE 变量正确)
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: Config file links.conf not found!"
    exit 1
fi

grep -v '^#' "$CONFIG_FILE" | grep -v '^$' | while IFS= read -r folder; do
    folder=$(echo "$folder" | xargs)
    TARGET_PATH="$HOME/$folder"
    SOURCE_PATH="$DATA_BASE/$folder"

    # 自动创建持久化源目录
    if [ ! -d "$SOURCE_PATH" ]; then
        echo "📂 Creating storage: $SOURCE_PATH"
        mkdir -p "$SOURCE_PATH"
    fi

    # 软链接逻辑 (保持你之前的优秀逻辑)
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

# --- 模块 2: 权限修复 ---
if [ -d "$DATA_BASE/.ssh" ]; then
    chmod 700 "$DATA_BASE/.ssh"
    chmod 600 "$DATA_BASE/.ssh/authorized_keys" 2>/dev/null
    chmod 600 "$DATA_BASE/.ssh/id_rsa" 2>/dev/null
fi

# --- 模块 3: 环境变量挂载 ---
# 关键优化：写入 .bashrc 的路径必须是现在的 ENV_FILE 绝对路径
LOAD_CMD="[ -f \"$ENV_FILE\" ] && source \"$ENV_FILE\""
MARKER="# --- Load Custom Env from Workspace Profile ---"

# 先清理旧的引用 (防止不同路径的配置堆积)
# 这一步可选，如果你希望同时保留多个环境配置则去掉
# sed -i '/Load Custom Env from/d' "$RC_FILE"

if ! grep -Fq "$ENV_FILE" "$RC_FILE"; then
    echo "" >> "$RC_FILE"
    echo "$MARKER" >> "$RC_FILE"
    echo "$LOAD_CMD" >> "$RC_FILE"
    echo "📝 Added env reference to $RC_FILE"
else
    echo "✅ .bashrc is already sourcing this env."
fi

# --- 模块 4: 立即生效 ---
source "$ENV_FILE"
echo "✨ Setup completed at $PROJECT_ROOT"
