#!/usr/bin/env bash
# 在本地从 alibaba/MNN 源码编出 iOS 用 MNN.xcframework（含 LLM），并拷贝到 IM-AI 工程。
# 依赖：cmake、Xcode、网络（首次需 clone）。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MNN_DIR="${MNN_DIR:-$REPO_ROOT/third_party/MNN}"
OUT_XC="$REPO_ROOT/apps/ios/IM-AI/Frameworks/MNN.xcframework"

echo "MNN 源码目录: $MNN_DIR"
if [[ ! -d "$MNN_DIR/.git" ]]; then
  echo "正在 clone MNN（浅克隆）…"
  mkdir -p "$(dirname "$MNN_DIR")"
  git clone --depth 1 https://github.com/alibaba/MNN.git "$MNN_DIR"
fi

IOS_BUILD_DIR="$MNN_DIR/package_scripts/ios"
if [[ ! -d "$IOS_BUILD_DIR" ]]; then
  echo "未找到 $IOS_BUILD_DIR，请检查 MNN 仓库是否完整。"
  exit 1
fi

CMAKE_EXTRA=${CMAKE_EXTRA:-"-DMNN_ARM82=ON -DMNN_LOW_MEMORY=ON -DMNN_SUPPORT_TRANSFORMER_FUSE=ON -DMNN_BUILD_LLM=ON -DMNN_CPU_WEIGHT_DEQUANT_GEMM=ON -DMNN_METAL=ON -DMNN_OPENCL=OFF -DMNN_SEP_BUILD=OFF"}

BUILD_DIR_DEV="$MNN_DIR/project/ios/MNN-iOS-CPU-GPU/Static/ios_64"
BUILD_DIR_SIM="$MNN_DIR/project/ios/MNN-iOS-CPU-GPU/Static/ios_sim_arm64"
echo "使用 CMake 直接构建 iOS arm64 + Simulator arm64 的 MNN.framework …"
rm -rf "$BUILD_DIR_DEV" "$BUILD_DIR_SIM"
mkdir -p "$BUILD_DIR_DEV" "$BUILD_DIR_SIM"

cmake -S "$MNN_DIR" -B "$BUILD_DIR_DEV" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE="$MNN_DIR/cmake/ios.toolchain.cmake" \
  -DMNN_METAL=ON \
  -DARCHS="arm64" \
  -DENABLE_BITCODE=0 \
  -DMNN_AAPL_FMWK=1 \
  -DMNN_SEP_BUILD=0 \
  -DMNN_ARM82=true \
  -DMNN_BUILD_SHARED_LIBS=false \
  -DMNN_USE_THREAD_POOL=OFF \
  $CMAKE_EXTRA

cmake --build "$BUILD_DIR_DEV" --target MNN -j"$(sysctl -n hw.ncpu)"

cmake -S "$MNN_DIR" -B "$BUILD_DIR_SIM" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE="$MNN_DIR/cmake/ios.toolchain.cmake" \
  -DMNN_METAL=ON \
  -DPLATFORM=SIMULATOR64 \
  -DARCHS="arm64" \
  -DENABLE_BITCODE=0 \
  -DMNN_AAPL_FMWK=1 \
  -DMNN_SEP_BUILD=0 \
  -DMNN_ARM82=true \
  -DMNN_BUILD_SHARED_LIBS=false \
  -DMNN_USE_THREAD_POOL=OFF \
  $CMAKE_EXTRA

cmake --build "$BUILD_DIR_SIM" --target MNN -j"$(sysctl -n hw.ncpu)"

DEV_FW="$BUILD_DIR_DEV/MNN.framework"
SIM_FW="$BUILD_DIR_SIM/MNN.framework"
if [[ ! -d "$DEV_FW" || ! -d "$SIM_FW" ]]; then
  echo "未找到构建产物: $DEV_FW 或 $SIM_FW"
  exit 1
fi

mkdir -p "$(dirname "$OUT_XC")"
rm -rf "$OUT_XC"
xcodebuild -create-xcframework -framework "$DEV_FW" -framework "$SIM_FW" -output "$OUT_XC"
echo "已输出: $OUT_XC"
