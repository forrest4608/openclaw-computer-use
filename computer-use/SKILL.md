---
name: computer-use
description: Vision-based non-invasive macOS desktop automation. See screen → Think → Act. Use this skill when the user asks you to operate any application on their computer.
metadata: { "openclaw": { "emoji": "🖱️", "requires": { "bins": ["cliclick", "python3"], "model_features": ["vision"] } } }
---

# 🖱️ Computer Use - macOS Desktop Automation

A vision-based, non-invasive automation skill that lets the AI **see your screen** and **control your computer** — operating any application through visual understanding, just like a human would.

## Core Workflow

```
📸 Screenshot → 🧠 AI Vision Analysis → 🖱️ Mouse/Keyboard Action → 🔄 Verify Result
```

## Available Tools

### 1. 📸 Screenshot (Capture Screen)
```bash
# Full screen
bash skills/computer-use/scripts/screenshot.sh

# Specific region (x,y,w,h)
bash skills/computer-use/scripts/screenshot.sh "100,200,800,600"
```
Returns the file path to the captured JPEG screenshot (auto-compressed). Use the `image` tool to view and analyze it.

### 2. 🖱️ Mouse Click
```bash
# Left click at coordinates
bash skills/computer-use/scripts/click.sh click <x> <y>

# Right click
bash skills/computer-use/scripts/click.sh right-click <x> <y>

# Double click  
bash skills/computer-use/scripts/click.sh double-click <x> <y>

# Drag from (x1,y1) to (x2,y2)
bash skills/computer-use/scripts/click.sh drag <x1> <y1> <x2> <y2>

# Move mouse (no click)
bash skills/computer-use/scripts/click.sh move <x> <y>
```

### 3. ⌨️ Keyboard Input
```bash
# Type text
bash skills/computer-use/scripts/type-text.sh type "Hello World"

# Press a key
bash skills/computer-use/scripts/type-text.sh key return
bash skills/computer-use/scripts/type-text.sh key tab
bash skills/computer-use/scripts/type-text.sh key esc

# Keyboard shortcuts
bash skills/computer-use/scripts/type-text.sh shortcut "cmd+c"
bash skills/computer-use/scripts/type-text.sh shortcut "cmd+v"
bash skills/computer-use/scripts/type-text.sh shortcut "cmd+shift+s"
bash skills/computer-use/scripts/type-text.sh shortcut "cmd+space"
```

### 4. 🪟 Window Control
```bash
# Focus / bring app to front
bash skills/computer-use/scripts/window-control.sh focus "Safari"

# List all windows of an app
bash skills/computer-use/scripts/window-control.sh list "Finder"

# Resize window
bash skills/computer-use/scripts/window-control.sh resize "Safari" 1200 800

# Move window position
bash skills/computer-use/scripts/window-control.sh position "Safari" 100 100

# Minimize window
bash skills/computer-use/scripts/window-control.sh minimize "Safari"
```

### 5. ℹ️ Screen Info
```bash
# Get display resolution, mouse pos, active app
bash skills/computer-use/scripts/get-screen-info.sh
```

## Automation Flow (How to Use)

When the user asks you to operate an application:

1. **Focus the target app FIRST** → Always use `window-control.sh focus "AppName"` to bring the app to front. This works even if the app is running in the background. **DO NOT use Spotlight (Cmd+Space) to open apps.** Use `focus` instead.
2. **Take a screenshot** → Run `screenshot.sh` and read the image to understand the current UI state
3. **Analyze visually** → Identify UI elements and their approximate coordinates
4. **Perform action** → Click buttons, type text, use shortcuts
5. **Verify** → Take another screenshot to confirm the action succeeded
6. **Repeat** as needed

## Common App Names on macOS

When using `window-control.sh focus`, use the exact macOS app name:
- 企业微信 → `"企业微信"` (WeCom / Enterprise WeChat)
- 微信 → `"微信"` (WeChat)
- 飞书 → `"Lark"` or `"飞书"`
- Safari → `"Safari"`
- Chrome → `"Google Chrome"`
- VS Code → `"Code"`
- Finder → `"Finder"`

## Prerequisites

- **cliclick**: `brew install cliclick` ✅
- **screencapture**: built-in on macOS ✅  
- **Accessibility Permission**: The terminal app must have Accessibility access
  - Go to: **System Settings → Privacy & Security → Accessibility**
  - Enable the checkbox for your **Terminal** (or IDE terminal like VS Code)

## Important Notes (MUST READ)

- **COORDINATE MAPPING**: Screenshots are auto-resized to the logical screen resolution (1440x900). The coordinates you see in the image are EXACTLY the coordinates to pass to `click.sh`. **DO NOT multiply or scale coordinates.** Use them directly as-is.
- **Always use `focus` to activate apps, never Spotlight**
- Always take a screenshot first to understand the current UI state
- After each action, re-screenshot to verify the result

## Pro Tips (Reliability)

- **Prefer keyboard shortcuts over clicking** for common actions. Shortcuts are far more reliable than trying to visually locate small UI elements:
  - Search: `Cmd+F` (most apps)
  - New window/document: `Cmd+N`
  - Copy/Paste: `Cmd+C` / `Cmd+V`
  - Close: `Cmd+W`
  - Save: `Cmd+S`
  - Select All: `Cmd+A`
- **企业微信 (WeCom) tips**:
  - Use `Cmd+F` to open the global search bar
  - After searching, press `Return` to confirm, then click the result
