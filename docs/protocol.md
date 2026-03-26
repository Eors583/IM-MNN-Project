# 跨端 Socket 协议（IM-MNN）

本文档定义 **Android / iOS / PC（AI 桥）** 的最小互通协议。任何一端要接入，必须遵循这里的约定。

## 1. 传输与分帧

- **传输**：TCP
- **编码**：UTF-8
- **分帧**：以 `\n`（newline）分隔；**每行是一条完整 JSON**（不要把多条 JSON 拼在一行，也不要把一条 JSON 拆成多行）

Android 端实现位置：`apps/android/app/.../core/im/SocketManager.kt`  
PC AI 桥实现位置：`apps/android/tools/pc-ai-server/server.py`

## 2. 消息结构（SocketMessage）

每条消息为 JSON 对象，字段名固定（snake_case），与 Android 数据模型一致：

```json
{
  "id": "string",
  "content": "string",
  "sender": "string",
  "timestamp": 0,
  "status": "string",
  "is_sent_by_me": false,
  "message_type": "string"
}
```

字段说明：

- **id**：消息唯一标识。建议用 UUID（PC AI 桥如此实现），或时间戳拼接前缀（Android 心跳/系统消息如此实现）。
- **content**：文本内容；某些回执类消息用它承载“被确认的消息 id”（见下文）。
- **sender**：发送者昵称（用于 UI 展示与在 PC AI 桥侧拼接上下文）。
- **timestamp**：毫秒时间戳（Unix epoch in ms）。
- **status**：消息状态字符串（更多用于本地 UI/存储；跨端可忽略，但字段需存在）。
- **is_sent_by_me**：是否“我方发送”（Android 主要用于本地 UI 渲染；跨端可填 `false`，但字段需存在）。
- **message_type**：消息类型，决定对端如何处理。

## 3. message_type 取值与语义

类型常量在 Android：`apps/android/app/.../core/utils/Constants.kt`。

### 3.1 text（普通文本）

- **message_type**：`"text"`
- **content**：聊天文本
- **对端处理**：展示到聊天流；必要时生成回执（见 delivery_ack/read_ack，具体策略由各端实现）

### 3.2 heartbeat（心跳）

- **message_type**：`"heartbeat"`
- **content**：固定 `"heartbeat"`（Android 当前如此）
- **对端处理**：收到后直接忽略即可；用于维持连接活性/发现静默断连

### 3.3 system（系统消息）

- **message_type**：`"system"`
- **content**：系统提示文本（如“已连接/已断开”等）
- **对端处理**：可作为系统气泡展示或记录日志；PC AI 桥会忽略

### 3.4 delivery_ack（送达回执）

- **message_type**：`"delivery_ack"`
- **content**：**被确认“已送达”的原消息 id**
- **对端处理**：把对应消息状态置为 delivered（或等价状态）

### 3.5 read_ack（已读回执）

- **message_type**：`"read_ack"`
- **content**：锚点消息 id（Android 注释：为该会话中最后一条“对方发来的文本消息”的 id）
- **对端处理**：把锚点之前（或至锚点）的消息状态置为 read（具体范围由端实现，但必须能找到这条 id）

## 4. status 取值（建议）

同样来源于 Android `Constants.kt`：

- `sending`
- `sent`
- `delivered`
- `read`
- `failed`

说明：

- 这是“端内状态”为主；跨端互通阶段可以只保证字段存在、值在集合内即可。

## 5. 兼容性与版本策略（建议）

目前协议没有显式版本字段。为降低后续演进成本，建议：

- 在不破坏旧字段的前提下 **只做向后兼容扩展**（新增字段对旧端应可忽略）
- 若必须做不兼容变更：新增 `protocol_version` 字段并在握手/首包中协商（后续可在本仓新增 `docs/protocol-versioning.md`）

