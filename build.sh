#!/usr/bin/env bash
set -euo pipefail

echo "===== Linglong Store build.sh ====="
echo "CWD: $(pwd)"
echo "User: $(whoami || true)"

echo ">>> 切换到 Debian 10 的归档源"
cat >/etc/apt/sources.list << 'SRC'
deb http://archive.debian.org/debian buster main contrib non-free
deb http://archive.debian.org/debian buster-updates main contrib non-free
deb http://archive.debian.org/debian-security buster/updates main contrib non-free
SRC

# 不校验过期时间（archive 里的 Release 都很久了）
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid

echo ">>> /etc/apt/sources.list:"
cat /etc/apt/sources.list

echo ">>> apt-get update"
apt-get update

echo ">>> 安装系统依赖 (GTK3 + WebKit2GTK 4.0 + 构建工具)"
apt-get install -y \
  curl \
  wget \
  git \
  file \
  build-essential \
  pkg-config \
  libgtk-3-dev \
  libwebkit2gtk-4.0-dev \
  libjavascriptcoregtk-4.0-dev \
  libsoup2.4-dev \
  libayatana-appindicator3-dev \
  librsvg2-dev \
  patchelf \
  xdg-utils

echo ">>> 安装 Node 18 (NodeSource)"
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

echo "Node version: $(node -v)"
echo "npm version: $(npm -v)"

echo ">>> 安装 Rust (rustup)"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# 加载 Rust 环境
# shellcheck disable=SC1090
. "$HOME/.cargo/env"

echo "Rust version: $(rustc -V || true)"
echo "Cargo version: $(cargo -V || true)"

echo ">>> 启用 pnpm（corepack）"
corepack enable
corepack prepare pnpm@9 --activate

echo "pnpm version: $(pnpm -v)"

echo ">>> 进入 workspace 目录"
cd /workspace

echo ">>> 安装前端依赖 (pnpm install --frozen-lockfile)"
pnpm install --frozen-lockfile

echo ">>> 生产构建 (pnpm build:pro)"
pnpm build:pro

echo "===== build.sh 完成 ====="
