# OpenClaw 自定义 Skill 注册完整指南

> 本文档总结了从零开始注册一个 OpenClaw 自定义 Skill 的完整流程，基于 `computer-use` skill 的实际排错经验整理。
> OpenClaw 版本：2026.2.15

---

## 一、Skill 的最小文件结构

一个 OpenClaw Skill **只需要两个文件**：

```text
your-skill/
├── SKILL.md       # 必须 — Skill 定义文件（注入 Agent 的系统 prompt）
└── _meta.json     # 必须 — Skill 元数据（OpenClaw 用于识别 Skill）
```

### 1. `SKILL.md`（核心文件）

这是最重要的文件。OpenClaw 会读取它并注入 Agent 的系统 prompt，让 Agent 知道这个 Skill 存在以及如何使用它。

**格式要求：**

```markdown
---
name: your-skill-name
description: 一句话描述你的 Skill 做什么。当 Agent 需要决定是否使用此 Skill 时会参考这段描述。
metadata: { "openclaw": { "emoji": "🔧", "requires": { "bins": ["python3"], "model_features": ["vision"] } } }
---

# Your Skill Name

详细说明 Skill 的功能、使用方法、命令格式等...
```

**关键字段说明：**

| 字段 | 必须 | 说明 |
|------|------|------|
| `name` | ✅ | Skill 的唯一标识符，必须与目录名一致 |
| `description` | ✅ | Agent 用来判断何时使用此 Skill 的描述 |
| `metadata` | ✅ | OpenClaw 的元数据，包含 emoji 和依赖声明 |
| `metadata.openclaw.emoji` | 推荐 | 在 `openclaw skills list` 中显示的图标 |
| `metadata.openclaw.requires.bins` | 可选 | 系统依赖（如 `cliclick`, `python3`） |
| `metadata.openclaw.requires.model_features` | 可选 | 模型能力需求（如 `vision`） |
| `metadata.openclaw.requires.env` | 可选 | 环境变量需求（如 `API_KEY`） |
| `metadata.openclaw.primaryEnv` | 可选 | 主要环境变量名（用于 openclaw.json 配置） |

**⚠️ 注意事项：**
- 命令路径使用**相对路径**，基于 `~/.openclaw/workspace/`，例如：`bash skills/your-skill/scripts/run.sh`
- `description` 要写清楚**何时**应该使用这个 Skill，Agent 靠这段文字来决策


### 2. `_meta.json`

```json
{
  "ownerId": "local",
  "slug": "your-skill-name",
  "version": "1.0.0",
  "publishedAt": 1771333600000
}
```

**说明：**
- `ownerId`: 本地开发的 Skill 用 `"local"`
- `slug`: 必须与目录名和 `SKILL.md` 中的 `name` 一致
- `version`: 语义化版本号
- `publishedAt`: 时间戳（毫秒），可以用 `date +%s000` 生成

### 3. `manifest.json`（**不需要**）

经验证，`baidu-search`、`feishu-deep-research` 等正常工作的 Skill 都没有 `manifest.json`。此文件**不是必须的**。

---

## 二、注册步骤

### Step 1: 放置 Skill 文件

将 Skill 目录放到 OpenClaw workspace 下：

```bash
# 方式 A：直接放置
cp -r your-skill ~/.openclaw/workspace/skills/

# 方式 B：符号链接（开发时推荐）
ln -s /path/to/your-skill ~/.openclaw/workspace/skills/your-skill
```

### Step 2: 在 `openclaw.json` 中注册

编辑 `~/.openclaw/openclaw.json`，在 `skills.entries` 中添加你的 Skill：

```json
{
  "skills": {
    "entries": {
      "your-skill": {}
    }
  }
}
```

如果 Skill 需要 API Key，可以在这里配置：

```json
{
  "skills": {
    "entries": {
      "your-skill": {
        "apiKey": "your-api-key-here"
      }
    }
  }
}
```

**⚠️ 这一步容易遗漏！** 即使文件放对了位置，如果没有在 `openclaw.json` 中注册，`openclaw skills list` 可能显示 Skill 存在，但 Agent 的系统 prompt 不会包含它。

### Step 3: 清除系统 prompt 缓存（关键！）

**OpenClaw 会缓存 Agent 的系统 prompt**（包含 Skill 列表）到 `sessions.json`。安装新 Skill 后必须清除！

```bash
rm -f ~/.openclaw/agents/main/sessions/sessions.json
rm -f ~/.openclaw/agents/main/sessions/*.jsonl
```

> **不清除这个缓存是最常见的"坑"。** 你会发现 `openclaw skills list` 显示 Skill 已就绪，但 Agent 依然不知道它的存在——因为它用的是旧的缓存 prompt。

### Step 4: 重启 Gateway

```bash
# 方法 1：如果 Gateway 是通过 launchctl 管理的
openclaw gateway stop
sleep 2
openclaw gateway

# 方法 2：如果 Gateway 是手动启动的
kill -9 $(lsof -ti :18789) 2>/dev/null
sleep 2
openclaw gateway
```

### Step 5: 验证

```bash
# 检查 Skill 是否被识别
openclaw skills list

# 应该看到类似：
# │ ✓ ready │ 🔧 your-skill │ Your description... │ openclaw-workspace │
```

然后通过飞书发送消息测试 Agent 是否能调用你的 Skill。

---

## 三、排错清单

当 Skill 不工作时，按以下顺序排查：

### Level 1: Skill 是否被识别？

```bash
openclaw skills list
```

**如果 Skill 没有出现：**
- [ ] `SKILL.md` 是否在 `~/.openclaw/workspace/skills/your-skill/` 目录下？
- [ ] `SKILL.md` 的 frontmatter 格式是否正确（有 `name`, `description`, `metadata`）？
- [ ] `_meta.json` 是否存在？
- [ ] 符号链接是否指向正确？ `ls -la ~/.openclaw/workspace/skills/your-skill`

### Level 2: Agent 是否知道 Skill？

发送消息后查看 Agent 回复。如果 Agent 说"我无法做到"：

- [ ] `openclaw.json` 的 `skills.entries` 中是否有你的 Skill？
- [ ] `sessions.json` 缓存是否已清除？
- [ ] Gateway 是否已重启？

**验证缓存是否包含你的 Skill：**

```bash
python3 -c "
import json
with open('$HOME/.openclaw/agents/main/sessions/sessions.json') as f:
    data = json.load(f)
for key, val in data.items():
    report = val.get('systemPromptReport', {})
    skills = report.get('skills', {}).get('entries', [])
    if skills:
        print('Skills in prompt:', [s['name'] for s in skills])
"
```

### Level 3: 脚本是否能正确执行？

- [ ] 脚本是否有执行权限？ `chmod +x scripts/*.sh`
- [ ] 命令路径是否正确？（相对于 `~/.openclaw/workspace/`）
- [ ] 脚本是否能在终端中手动执行成功？

### Level 4: 图片/文件是否能被 Agent 读取？

- [ ] 文件路径是否在 OpenClaw 允许的目录下？（`/tmp/` **不被允许**！）
- [ ] 推荐使用 `~/.openclaw/workspace/` 下的子目录

### Level 5: 坐标/视觉相关

- [ ] Retina 显示器的截图是 2x 物理分辨率，需缩放到逻辑分辨率
- [ ] `cliclick` 使用逻辑坐标系（1440x900），不是物理像素（2880x1800）

### Level 6: 会话历史问题

如果遇到 `400 Item of type 'reasoning' was provided without its required following item`：

```bash
rm -f ~/.openclaw/agents/main/sessions/*.jsonl
# 然后重启 Gateway
```

---

## 四、OpenClaw 内部工作机制（经验总结）

### 系统 prompt 生成流程

```
openclaw.json (skills.entries)
    ↓
扫描 ~/.openclaw/workspace/skills/*/SKILL.md
    ↓
读取 SKILL.md frontmatter + 内容
    ↓
注入到 Agent 的系统 prompt 中
    ↓
缓存到 sessions.json（后续请求直接使用缓存！）
```

### 关键路径

| 路径 | 用途 |
|------|------|
| `~/.openclaw/openclaw.json` | 全局配置（skills 注册、channel 配置、模型设置） |
| `~/.openclaw/workspace/skills/` | Skill 文件存放目录 |
| `~/.openclaw/agents/main/sessions/sessions.json` | **系统 prompt 缓存**（！关键） |
| `~/.openclaw/agents/main/sessions/*.jsonl` | 会话历史记录 |
| `/tmp/openclaw/openclaw-YYYY-MM-DD.log` | 详细运行日志 |

### Agent 工具列表

OpenClaw Agent 内置以下工具（不需要自定义 Skill 提供）：

- `exec` — 执行 Shell 命令
- `read` / `write` / `edit` — 文件操作
- `image` — 读取和分析图片
- `browser` — 浏览器控制
- `web_search` / `web_fetch` — 网络搜索
- `message` — 消息发送
- `canvas` — 画布操作
- `cron` — 定时任务
- `process` — 进程管理
- `tts` — 文字转语音

你的 Skill 不需要定义新的 "tool"——只需要在 SKILL.md 中告诉 Agent 如何通过 `exec` 工具来调用你的脚本。

---

## 五、Quick Start 模板

最快创建一个新 Skill 的步骤：

```bash
# 1. 创建目录
SKILL_NAME="my-awesome-skill"
mkdir -p ~/.openclaw/workspace/skills/$SKILL_NAME/scripts

# 2. 创建 _meta.json
cat > ~/.openclaw/workspace/skills/$SKILL_NAME/_meta.json << 'EOF'
{
  "ownerId": "local",
  "slug": "my-awesome-skill",
  "version": "1.0.0",
  "publishedAt": 1771344000000
}
EOF

# 3. 创建 SKILL.md
cat > ~/.openclaw/workspace/skills/$SKILL_NAME/SKILL.md << 'EOF'
---
name: my-awesome-skill
description: Describe what your skill does. The Agent reads this to decide when to use it.
metadata: { "openclaw": { "emoji": "⚡" } }
---

# My Awesome Skill

## Usage

```bash
bash skills/my-awesome-skill/scripts/run.sh "<argument>"
```

## Instructions

Tell the Agent how and when to use your skill here...
EOF

# 4. 创建脚本
cat > ~/.openclaw/workspace/skills/$SKILL_NAME/scripts/run.sh << 'EOF'
#!/bin/bash
echo "Hello from my-awesome-skill! Argument: $1"
EOF
chmod +x ~/.openclaw/workspace/skills/$SKILL_NAME/scripts/run.sh

# 5. 注册到 openclaw.json（手动编辑，在 skills.entries 中添加）
# "my-awesome-skill": {}

# 6. 清缓存 + 重启
rm -f ~/.openclaw/agents/main/sessions/sessions.json
rm -f ~/.openclaw/agents/main/sessions/*.jsonl
kill -9 $(lsof -ti :18789) 2>/dev/null; sleep 2; openclaw gateway
```

---

*最后更新：2026-02-18*
*基于 computer-use skill 排错经验整理*
