#!/usr/bin/env bash
set -euo pipefail

echo "[*] 初始化/更新 submodules（recursive）"
git submodule sync --recursive
git submodule update --init --recursive

echo
echo "[*] Submodule 状态："
git submodule status --recursive

echo
echo "[*] 完成。接下来："
echo "    - Android: 进入 apps/android 按其 README 运行"
echo "    - iOS:     进入 apps/ios 按其 README 运行"

