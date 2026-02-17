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
├── manifest.json         # Skill metadata (standard OpenClaw format)
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

## 📄 License

MIT
