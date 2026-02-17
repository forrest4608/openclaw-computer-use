---
name: computer-use
description: Vision-based non-invasive macOS desktop automation. See screen → Think → Act.
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
bash {baseDir}/scripts/screenshot.sh

# Specific region (x,y,w,h)
bash {baseDir}/scripts/screenshot.sh "100,200,800,600"
```
Returns the file path to the captured screenshot. Use `view_file` to analyze it.

### 2. 🖱️ Mouse Click
```bash
# Left click at coordinates
bash {baseDir}/scripts/click.sh click <x> <y>

# Right click
bash {baseDir}/scripts/click.sh right-click <x> <y>

# Double click  
bash {baseDir}/scripts/click.sh double-click <x> <y>

# Drag from (x1,y1) to (x2,y2)
bash {baseDir}/scripts/click.sh drag <x1> <y1> <x2> <y2>

# Move mouse (no click)
bash {baseDir}/scripts/click.sh move <x> <y>
```

### 3. ⌨️ Keyboard Input
```bash
# Type text
bash {baseDir}/scripts/type-text.sh type "Hello World"

# Press a key
bash {baseDir}/scripts/type-text.sh key return
bash {baseDir}/scripts/type-text.sh key tab
bash {baseDir}/scripts/type-text.sh key esc

# Keyboard shortcuts
bash {baseDir}/scripts/type-text.sh shortcut "cmd+c"
bash {baseDir}/scripts/type-text.sh shortcut "cmd+v"
bash {baseDir}/scripts/type-text.sh shortcut "cmd+shift+s"
bash {baseDir}/scripts/type-text.sh shortcut "cmd+space"
```

### 4. 🪟 Window Control
```bash
# Focus / bring app to front
bash {baseDir}/scripts/window-control.sh focus "Safari"

# List all windows of an app
bash {baseDir}/scripts/window-control.sh list "Finder"

# Resize window
bash {baseDir}/scripts/window-control.sh resize "Safari" 1200 800

# Move window position
bash {baseDir}/scripts/window-control.sh position "Safari" 100 100

# Minimize window
bash {baseDir}/scripts/window-control.sh minimize "Safari"
```

### 5. ℹ️ Screen Info
```bash
# Get display resolution, mouse pos, active app
bash {baseDir}/scripts/get-screen-info.sh
```

## Automation Flow (How to Use)

When the user asks you to operate an application:

1. **Get screen info** → Run `get-screen-info.sh` to know resolution and active app
2. **Focus the target app** → Run `window-control.sh focus "AppName"`  
3. **Take a screenshot** → Run `screenshot.sh` and then `view_file` the result
4. **Analyze visually** → Identify UI elements and their approximate coordinates
5. **Perform action** → Click buttons, type text, use shortcuts
6. **Verify** → Take another screenshot to confirm the action succeeded
7. **Repeat** as needed

## Prerequisites

- **cliclick**: `brew install cliclick` ✅
- **screencapture**: built-in on macOS ✅  
- **Accessibility Permission**: The terminal app must have Accessibility access
  - Go to: **System Settings → Privacy & Security → Accessibility**
  - Enable the checkbox for your **Terminal** (or IDE terminal like VS Code)

## Important Notes

- Coordinates are absolute screen pixels (origin at top-left)
- Always take a screenshot first to understand the current UI state
- After each action, re-screenshot to verify the result
- Use `get-screen-info.sh` to get the display resolution for coordinate calibration
