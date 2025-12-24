# Portable Workspace Profile

这是我的个人跨平台工作环境配置。旨在解决无 Root 权限、目录不固定的服务器环境下的工具链管理问题。

## 核心功能

* **0 依赖**: 只要有 bash 和 git 就能跑。
* **动静分离**: 脚本在 `bin/`，日志在 `logs/`，数据在 `.permanent_env/`。
* **自动修正**: 自动识别当前绝对路径，修改 `PATH` 和 `PYTHONPATH`。
* **工具集成**: 内置 VSCode Server、SSH Tunnel 管理、uv (Python 包管理) 配置。

## 🚀 快速开始 (Bootstrap)

假设你登录了一台新服务器，分配的目录是 `/data2/zhangdw`：

```bash
# 1. 克隆项目
cd /data2/zhangdw
git clone [https://github.com/yourname/workspace-profile.git](https://github.com/yourname/workspace-profile.git)
cd workspace-profile

# 2. 一键初始化
# 这会自动创建 logs, run 目录，并建立 .bashrc 的软链接和环境变量引用
./bootstrap.sh

# 3. 立即生效
source ~/.bashrc
```
