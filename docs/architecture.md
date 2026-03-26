# 项目集群架构概览

本仓库是一个母仓（聚合仓），通过 Git Submodule 聚合多端同一产品的实现。

## 1. 端侧角色

- **Android App（apps/android）**
  - 作为“客户端”连接局域网对端，或作为“服务端”监听 TCP 端口等待连接
  - 负责 UI、消息存储（Room）、连接状态与心跳
  - 可选：端侧离线 AI（MNN LLM）问答（模型由用户下载，不随 APK 打包）

- **iOS App（apps/ios）**
  - 目标与 Android 对齐：相同的局域网 IM +（可选）AI 能力
  - 当前处于从 Android 方案迁移/对齐阶段（先把协议与产品能力拉齐）

- **PC AI 桥（apps/android/tools/pc-ai-server）**
  - 一个可选组件：让手机把对话“接到 PC 上的 LLM”（Ollama 或 OpenAI 兼容接口）
  - 与 App 使用相同的 TCP+JSON 行协议，连接后对 `text` 消息生成回复再写回

## 2. 数据流（简化）

```text
手机A（服务端） <--- TCP+JSONL ---> 手机B（客户端）

或：

手机（客户端） <--- TCP+JSONL ---> PC AI 桥（服务端） ---> Ollama/OpenAI兼容模型
```

协议约定见 `docs/protocol.md`。

## 3. 母仓职责边界（建议）

母仓负责：

- 子仓聚合与版本指针管理（submodule）
- 跨端契约（协议、错误码、字段命名、兼容策略）
- 一键脚本与 CI 门禁（确保 submodule 可用、基础构建/检查）
- 协作流程（贡献指南、发版说明）

子仓负责：

- 各端具体实现与依赖管理
- 各端 UI/业务逻辑
- 各端平台特有能力（权限、网络、存储、系统 API 等）

