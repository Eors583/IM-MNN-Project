# IM-MNN-Project

一个“母仓库 / 项目集群”示例：用 **Git Submodule** 聚合多端同一产品的实现（Android / iOS / Flutter），并附带 PC 端 AI 聊天桥接服务（位于 Android 子仓的 `tools/pc-ai-server`）。

## 这是什么

- **同一产品，多端落地**：局域网 IM 聊天 +（可选）端侧/本地 AI 问答能力。
- **母仓只做聚合与规范**：统一入口文档、协议约定、协作流程、脚本与 CI；具体业务代码在各端子仓。

## 仓库结构

```text
.
├─ apps/
│  ├─ android/        # Android 原生实现（Kotlin + Compose）
│  ├─ ios/            # iOS 原生实现（与 Android 协议/能力对齐）
│  └─ flutter/        # Flutter 多端实现（Dart）
├─ docs/              # 跨端约定（协议/架构/协作）
├─ scripts/           # 一键初始化、同步 submodule 等脚本
└─ .github/workflows/ #（可选）CI：校验 submodule、跑基础构建/检查
```

## 快速开始

### 克隆（推荐）

```bash
git clone --recurse-submodules <母仓地址>
```

若已克隆但没拉到子仓：

```bash
git submodule update --init --recursive
```

### 初始化脚本（Windows / macOS / Linux）

- Windows PowerShell：

```powershell
.\scripts\init.ps1
```

- macOS / Linux：

```bash
./scripts/init.sh
```

脚本会做：

- 初始化并更新 submodule（递归）
- 输出当前 submodule 指针与状态提示

## 子项目入口

- **Android**：见 `apps/android/README.md`
- **iOS**：见 `apps/ios/README.md`（目前文档已对齐产品说明，代码迁移进行中）
- **Flutter**：见 `apps/flutter/README.md`

## 跨端协议（重要）

各端（Android / iOS / Flutter 互通、Android <-> PC AI 桥等）建议统一遵循：

- **传输**：TCP
- **编码**：UTF-8
- **分帧**：`\n` 分行（每行一条 JSON）
- **消息体**：`SocketMessage` 结构（字段名固定）

详见 `docs/protocol.md`。

## 协作约定（建议）

- **改动子仓**：在 `apps/android` / `apps/ios` / `apps/flutter` 内各自开发、提交、推送到子仓远端
- **更新母仓指针**：回到母仓提交 submodule 指针更新（母仓只记录子仓 commit）
- **PR/发版**：母仓 PR 中说明本次包含的 Android/iOS 子仓 commit / tag

更多细节见 `CONTRIBUTING.md`。
