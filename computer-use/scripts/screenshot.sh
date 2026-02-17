#!/bin/bash
# Computer Use - Screenshot Tool
# Usage: ./screenshot.sh [region]
# region format: x,y,w,h (optional, captures full screen if omitted)

OUTPUT_DIR="/tmp/computer-use"
mkdir -p "$OUTPUT_DIR"

TIMESTAMP=$(date +%s)
SCREENSHOT_PATH="${OUTPUT_DIR}/screen_${TIMESTAMP}.png"

if [ -n "$1" ]; then
    # Capture specific region: x,y,w,h
    IFS=',' read -r X Y W H <<< "$1"
    screencapture -x -R"${X},${Y},${W},${H}" "$SCREENSHOT_PATH"
else
    # Capture full screen
    screencapture -x "$SCREENSHOT_PATH"
fi

if [ -f "$SCREENSHOT_PATH" ]; then
    echo "$SCREENSHOT_PATH"
else
    echo "ERROR: Screenshot failed" >&2
    exit 1
fi
