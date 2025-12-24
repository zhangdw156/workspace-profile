#!/bin/bash
# 文件名: bootstrap.sh

# 获取当前目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Initializing Workspace at: $PROJECT_ROOT"

# 1. 创建必要的运行时目录 (Git 会忽略这些)
mkdir -p "$PROJECT_ROOT/logs"
mkdir -p "$PROJECT_ROOT/run"
mkdir -p "$PROJECT_ROOT/.permanent_env"

# 2. 赋予脚本执行权限
chmod +x "$PROJECT_ROOT/bootstrap.sh"
chmod +x "$PROJECT_ROOT/sbin/"*.sh
chmod +x "$PROJECT_ROOT/bin/"*.sh 2>/dev/null

# 3. 运行核心配置
source "$PROJECT_ROOT/sbin/setup.sh"

echo "🎉 Workspace Ready! Please run: source ~/.bashrc"
