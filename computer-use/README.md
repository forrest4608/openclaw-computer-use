# 🖱️ Computer Use — macOS Desktop Automation Skill

An OpenClaw skill that enables AI Agents to interact with your macOS desktop visually. It follows a **"See → Think → Act"** loop to automate tasks across any application.

> **Note**: This skill is designed for **macOS** only.

---

## ✨ Features

- **📸 Screen Analysis**: Captures screenshots (auto-compressed JPEG at logical resolution) for the AI to understand the current state.
- **🖱️ Human-like Mouse Control**: Clicks, double-clicks, right-clicks, and drags with **Bézier curve** mouse movement to simulate natural human hand motion.
- **⌨️ Smart Keyboard Input**: Intelligent typing with automatic Chinese character detection (clipboard paste mode) and full shortcut support.
- **🪟 Window Management**: Focus/activate apps (including background apps), list windows, resize, reposition, and minimize.
- **🎯 Retina-aware Coordinates**: Screenshots are automatically resized to match the logical screen resolution (e.g., 1440x900), ensuring 1:1 coordinate mapping with `cliclick`.

---

## 💡 Design Philosophy

**"Visual is the new API."**

The core mission of this skill is **100% Non-invasive Control**:

1. **🛡️ Anti-Detection**: By strictly using visual feedback (screenshots) and hardware-level input simulation, we bypass sophisticated anti-fraud and anti-bot systems that monitor DOM injection or API hooks.
2. **🌐 Universal Compatibility**: Whether it's a native macOS app, a complex web SPA, or a remote desktop session, if a human can see and click it, this skill can control it.
3. **🔒 Zero Intrusion**: No code injection, no reverse engineering of private protocols. We interact with the software exactly as the developer intended—through the UI.
4. **🤖 Human-like Behavior**: Mouse movements follow Bézier curves with micro-jitter and random delays, making automation virtually indistinguishable from human interaction.

---

## 🛠️ Prerequisites

### 1. Install `cliclick`

```bash
brew install cliclick
```

### 2. Python 3 (for Bézier curve generation)

```bash
python3 --version  # macOS ships with Python 3
```

### 3. Grant Accessibility Permissions (Critical)

For the script to control your mouse and keyboard, you **must** grant Accessibility permissions:

1. Open **System Settings** → **Privacy & Security** → **Accessibility**.
2. Click the `+` button.
3. Add your terminal application (e.g., `Terminal`, `iTerm2`, or `Visual Studio Code`).
4. Ensure the toggle is **ON**.

> ⚠️ **Without this, the script will fail silently or throw permission errors.**

---

## 🚀 Installation

### Step 1: Clone or Symlink

```bash
# Option A: Clone directly
cd ~/.openclaw/workspace/skills
git clone https://github.com/forrest4608/openclaw-computer-use.git computer-use

# Option B: Symlink (for development)
ln -s /path/to/your/computer-use ~/.openclaw/workspace/skills/computer-use
```

### Step 2: Register in OpenClaw config

Add `"computer-use": {}` to your `~/.openclaw/openclaw.json` under `skills.entries`:

```json
{
  "skills": {
    "entries": {
      "computer-use": {}
    }
  }
}
```

### Step 3: Clear session cache & restart Gateway

```bash
# Clear cached system prompt (required for new skills!)
rm -f ~/.openclaw/agents/main/sessions/sessions.json
rm -f ~/.openclaw/agents/main/sessions/*.jsonl

# Restart gateway
kill -9 $(lsof -ti :18789) 2>/dev/null
sleep 2
openclaw gateway
```

> **Important**: OpenClaw caches the system prompt (including skill list) in `sessions.json`. After installing a new skill, you **must** delete this file to force a prompt regeneration. Otherwise the Agent won't know about the new skill.

---

## 📖 Usage

Once installed, ask your OpenClaw Agent (via Feishu, etc.) to perform desktop tasks:

- *"打开企业微信，找到前沿研究组的群"*
- *"Take a screenshot of my desktop."*
- *"Open TextEdit and type 'Hello World'."*
- *"Find the Submit button on the screen and click it."*
- *"Focus Safari and navigate to google.com."*

---

## 🔧 Key Technical Details

### Retina Coordinate Mapping

On Retina displays, `screencapture` captures at 2x physical resolution (e.g., 2880×1800), but `cliclick` uses logical coordinates (e.g., 1440×900). Our `screenshot.sh` **automatically detects and resizes** to the logical resolution, so image coordinates map 1:1 to screen coordinates.

### Human-like Mouse Movement

`click.sh` uses `gen_bezier.py` to generate a cubic Bézier curve path between the current mouse position and the target. This includes:
- Random control points for natural arcs
- Micro-jitter (±2px) to simulate hand tremor
- Variable step delays (1-3ms) for speed variation

### Smart Chinese Input

`type-text.sh` automatically detects non-ASCII characters and switches to clipboard paste mode (`pbcopy` + `Cmd+V`) instead of direct key simulation, ensuring perfect Chinese/Japanese/Korean text input.

---

## 🐛 Troubleshooting

### "Agent says 'I cannot control your desktop'"
**Cause**: Skill is not loaded into the Agent's system prompt.
**Fix**:
1. Verify `"computer-use": {}` is in `openclaw.json` → `skills.entries`
2. Delete `~/.openclaw/agents/main/sessions/sessions.json`
3. Restart the Gateway

### "image failed: Local media path is not under an allowed directory"
**Cause**: Screenshots saved to `/tmp/` which OpenClaw blocks.
**Fix**: Screenshots are now saved to `~/.openclaw/workspace/computer-use-screenshots/` (already fixed in current version).

### "Mouse clicks land in the wrong position"
**Cause**: Retina 2x scaling mismatch between screenshot resolution and `cliclick` coordinates.
**Fix**: `screenshot.sh` now auto-resizes to logical resolution (already fixed in current version).

### "The terminal keeps grabbing focus!"
**Issue**: VS Code's integrated terminal grabs focus back after command finishes.
**Fix**: Use an external terminal, or note that this only affects manual testing — OpenClaw's `exec` tool runs in a separate process.

### "400 reasoning token error"
**Cause**: Corrupted reasoning tokens in session history (OpenAI API).
**Fix**: Delete all `.jsonl` files in `~/.openclaw/agents/main/sessions/`

---

## 📂 Project Structure

```text
computer-use/
├── SKILL.md              # Skill definition (injected into Agent's system prompt)
├── _meta.json            # Skill registration metadata
├── README.md             # This file
├── scripts/
│   ├── screenshot.sh     # Screen capture (auto-JPEG, Retina-aware resize)
│   ├── click.sh          # Mouse events (Bézier curve movement)
│   ├── gen_bezier.py     # Bézier path generator (Python)
│   ├── type-text.sh      # Keyboard input (Chinese-aware clipboard paste)
│   ├── window-control.sh # Window management (focus, list, resize, move)
│   └── get-screen-info.sh # Display info (resolution, active app)
└── docs/                 # Documentation and test reports
```

---

## 📝 OpenClaw 自定义 Skill 注册指南

> 以下内容基于 `computer-use` skill 的实际排错经验整理，适用于 OpenClaw 2026.2.15+。

### Skill 最小文件结构

一个 OpenClaw Skill **只需要两个文件**：

```text
your-skill/
├── SKILL.md       # 必须 — Skill 定义（注入 Agent 系统 prompt）
└── _meta.json     # 必须 — 元数据（OpenClaw 识别 Skill）
```

> **`manifest.json` 不需要。** 经验证，`baidu-search`、`feishu-deep-research` 等正常工作的 Skill 都没有此文件。

### SKILL.md 格式

```markdown
---
name: your-skill-name
description: 一句话描述，Agent 据此决定何时使用此 Skill。
metadata: { "openclaw": { "emoji": "🔧", "requires": { "bins": ["python3"], "model_features": ["vision"] } } }
---

# Your Skill Name

详细说明 Skill 的功能、使用方法、命令格式...
```

**关键字段：**

| 字段 | 必须 | 说明 |
|------|------|------|
| `name` | ✅ | 唯一标识，必须与目录名一致 |
| `description` | ✅ | Agent 判断何时使用此 Skill 的依据 |
| `metadata.openclaw.emoji` | 推荐 | `openclaw skills list` 中显示的图标 |
| `metadata.openclaw.requires.bins` | 可选 | 系统依赖（如 `cliclick`） |
| `metadata.openclaw.requires.model_features` | 可选 | 模型能力需求（如 `vision`） |

**⚠️ 命令路径使用相对路径**，基于 `~/.openclaw/workspace/`，例如：`bash skills/your-skill/scripts/run.sh`

### _meta.json 格式

```json
{
  "ownerId": "local",
  "slug": "your-skill-name",
  "version": "1.0.0",
  "publishedAt": 1771344000000
}
```

### 注册步骤

```bash
# 1. 放置文件（二选一）
cp -r your-skill ~/.openclaw/workspace/skills/          # 直接复制
ln -s /path/to/your-skill ~/.openclaw/workspace/skills/  # 符号链接（开发推荐）

# 2. 编辑 ~/.openclaw/openclaw.json，在 skills.entries 中添加：
#    "your-skill": {}

# 3. 清除系统 prompt 缓存（⚠️ 关键！最容易遗漏的一步）
rm -f ~/.openclaw/agents/main/sessions/sessions.json
rm -f ~/.openclaw/agents/main/sessions/*.jsonl

# 4. 重启 Gateway
kill -9 $(lsof -ti :18789) 2>/dev/null; sleep 2; openclaw gateway

# 5. 验证
openclaw skills list
# 应看到：✓ ready │ 🔧 your-skill │ ...
```

### 排错清单

当 Skill 不工作时，按以下顺序排查：

| Level | 症状 | 检查项 |
|-------|------|--------|
| 1 | `openclaw skills list` 看不到 | SKILL.md 的 frontmatter 格式是否正确？`_meta.json` 是否存在？ |
| 2 | Agent 说"我无法做到" | `openclaw.json` 的 `skills.entries` 是否已添加？**`sessions.json` 缓存是否已清除？** |
| 3 | 脚本执行失败 | 是否有执行权限？命令路径是否正确？（相对于 workspace） |
| 4 | 图片读取失败 | 文件是否在 workspace 目录下？（`/tmp/` 被 OpenClaw 拦截！） |
| 5 | 坐标偏移 | Retina 2x：截图需缩放到逻辑分辨率才能匹配 `cliclick` 坐标 |
| 6 | 400 reasoning 错误 | 删除 `~/.openclaw/agents/main/sessions/*.jsonl` |

### OpenClaw 内部机制

```
openclaw.json (skills.entries)
    ↓
扫描 ~/.openclaw/workspace/skills/*/SKILL.md
    ↓
读取 frontmatter + 内容 → 注入 Agent 系统 prompt
    ↓
缓存到 sessions.json（后续请求直接使用缓存！）
```

**关键路径：**

| 路径 | 用途 |
|------|------|
| `~/.openclaw/openclaw.json` | 全局配置（Skill 注册、模型、Channel） |
| `~/.openclaw/workspace/skills/` | Skill 文件目录 |
| `~/.openclaw/agents/main/sessions/sessions.json` | **系统 prompt 缓存**（⚠️ 关键） |
| `/tmp/openclaw/openclaw-YYYY-MM-DD.log` | 运行日志 |

> **Skill 不需要定义新的 "tool"**。Agent 已内置 `exec`、`image`、`read`、`write` 等工具。你的 SKILL.md 只需告诉 Agent 如何通过 `exec` 调用你的脚本即可。

---

## 📄 License

MIT

