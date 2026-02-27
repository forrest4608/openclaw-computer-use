#!/bin/bash
# Computer Use - Screenshot Tool
# Usage: ./screenshot.sh [region]
# region format: x,y,w,h (optional, captures full screen if omitted)

PATH="/usr/sbin:$PATH"
OUTPUT_DIR="/Users/zhigangliu/.openclaw/workspace/computer-use-screenshots"
mkdir -p "$OUTPUT_DIR"

TIMESTAMP=$(date +%s)
SCREENSHOT_RAW="${OUTPUT_DIR}/screen_${TIMESTAMP}_raw.png"
SCREENSHOT_PATH="${OUTPUT_DIR}/screen_${TIMESTAMP}.jpg"

if [ -n "$1" ]; then
    # Capture specific region: x,y,w,h
    IFS=',' read -r X Y W H <<< "$1"
    screencapture -x -R"${X},${Y},${W},${H}" "$SCREENSHOT_RAW"
else
    # Capture full screen
    screencapture -x "$SCREENSHOT_RAW"
fi

# Convert to JPEG and resize to LOGICAL resolution (1440 wide on Retina 2x)
# This ensures image coordinates == cliclick coordinates (no scaling needed!)
if [ -f "$SCREENSHOT_RAW" ]; then
    # Get actual width and calculate logical width (Retina = 2x)
    PHYS_W=$(sips -g pixelWidth "$SCREENSHOT_RAW" 2>/dev/null | tail -1 | awk '{print $2}')
    LOGICAL_W=$((PHYS_W / 2))
    sips -s format jpeg -s formatOptions 70 -Z "$LOGICAL_W" "$SCREENSHOT_RAW" --out "$SCREENSHOT_PATH" >/dev/null 2>&1
    rm -f "$SCREENSHOT_RAW"
fi

if [ -f "$SCREENSHOT_PATH" ]; then
    echo "$SCREENSHOT_PATH"
else
    echo "ERROR: Screenshot failed" >&2
    exit 1
fi
