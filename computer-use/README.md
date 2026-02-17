# 🖥️ Computer Use (macOS Automation Skill)

An OpenClaw skill that enables AI Agents to interact with your macOS desktop visually. It follows a "See → Think → Act" loop to automate tasks across any application.

> **Note**: This skill is designed for **macOS** only.

---

## ✨ Features

*   **📸 Screen Analysis**: Captures screenshots for the AI to understand the current state.
*   **🖱️ Mouse Control**: Clicks, double-clicks, right-clicks, and drags via `cliclick`.
*   **⌨️ Keyboard Input**: Types text and executes shortcuts (e.g., `Cmd+C`, `Cmd+V`).
*   **🪟 Window Management**: Focuses apps, lists windows, and manages positions via AppleScript.
*   **🔍 System Info**: Retrieves screen resolution and active window details.

---

## 🛠️ Prerequisites

Before installing, ensure you have the necessary system dependencies.

### 1. Install `cliclick`
This tool is required for simulating mouse and keyboard events.

```bash
brew install cliclick
```

### 2. Grant Accessibility Permissions (Critical)
For the script to control your mouse and keyboard, you **must** grant Accessibility permissions to your Terminal application (e.g., Platform IDE, Terminal, iTerm2, or VS Code).

1.  Open **System Settings** -> **Privacy & Security** -> **Accessibility**.
2.  Click the `+` button.
3.  Add your terminal application (e.g., `Visual Studio Code` or `Terminal`).
4.  Ensure the toggle is **ON**.

> ⚠️ **Without this, the script will fail silently or throw permission errors.**

---

## 🚀 Installation

### Option A: Install to OpenClaw (Recommended)

Navigate to your OpenClaw skills directory and clone this repository:

```bash
cd ~/.openclaw/workspace/skills
git clone https://github.com/your-username/computer-use.git
```

### Option B: Symlink (For Development)

If you are developing the skill locally, link your project folder to OpenClaw:

```bash
ln -s /path/to/your/computer-use ~/.openclaw/workspace/skills/computer-use
```

---

## 📖 Usage

Once installed, you can ask your OpenClaw Agent to perform desktop tasks.

**Examples:**

*   "Take a screenshot of my desktop."
*   "Open TextEdit and type 'Hello World'."
*   "Find the 'Submit' button on the screen and click it."
*   "Focus the 'Safari' window."

---

## 🔧 Troubleshooting

### 1. "The terminal keeps grabbing focus!"
**Issue**: When running commands from VS Code's integrated terminal, VS Code often grabs focus back after the command finishes.
**Solution**:
*   Use an external terminal (Terminal.app or iTerm2).
*   Or instruct the agent to chain commands: `... && sleep 1`.

### 2. "Typing output is garbled (English text becomes Chinese)"
**Issue**: macOS Input Method (IME) is set to Chinese/Pinyin.
**Solution**:
*   Switch your keyboard layout to **English (ABC)** before running automation tasks.
*   Or use the clipboard paste method (Agent instruction: "Copy text to clipboard and press Cmd+V").

### 3. "Permission denied" or Actions ignored
**Issue**: Accessibility permissions are missing or revoked.
**Solution**:
*   Go to System Settings > Accessibility.
*   Remove and re-add your Terminal app to reset permissions.

---

## 📂 Project Structure

```text
computer-use/
├── SKILL.md              # Skill definition and instructions for the Agent
├── README.md             # This file
├── scripts/              # Action scripts
│   ├── screenshot.sh     # Captures screen
│   ├── click.sh          # Handles mouse events
│   ├── type-text.sh      # Handles keyboard events
│   ├── window-control.sh # Manages windows
│   └── get-screen-info.sh # Gets resolution/focus
└── docs/                 # Documentation and logs
```

## 📄 License

MIT
